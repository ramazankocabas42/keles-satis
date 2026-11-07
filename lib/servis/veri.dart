import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../modeller.dart';
import 'bildirim.dart';

/// Firestore yolları ve yazma işlemleri.
///
/// satis_kullanicilar/{uid}           : {ad, firmaId}
/// satis_kodlar/{kod}                 : {firmaId}   (davet kodu → firma)
/// satis_firmalar/{fid}               : firma ayarları, üyeler, sayaç
/// satis_firmalar/{fid}/siparisler/{id}
class Veri {
  Veri._();

  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get kullanicilar =>
      _db.collection('satis_kullanicilar');
  static CollectionReference<Map<String, dynamic>> get kodlar =>
      _db.collection('satis_kodlar');
  static CollectionReference<Map<String, dynamic>> get firmalar =>
      _db.collection('satis_firmalar');
  static CollectionReference<Map<String, dynamic>> siparisler(String fid) =>
      firmalar.doc(fid).collection('siparisler');

  static int get simdi => DateTime.now().millisecondsSinceEpoch;

  static String yeniKod() {
    const harf = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(8, (_) => harf[r.nextInt(harf.length)]).join();
  }

  static Future<void> adKaydet(String uid, String ad) =>
      kullanicilar.doc(uid).set({'ad': ad.trim()}, SetOptions(merge: true));

  static Future<void> firmaKur(String uid, String ad, String firmaAdi) async {
    final f = firmalar.doc();
    final kod = yeniKod();
    final b = _db.batch();
    b.set(f, {
      'ad': firmaAdi.trim().toUpperCase(),
      'altyazi': 'SATIŞ & TİCARET',
      'sahip': uid,
      'uyeler': [uid],
      'yoneticiler': [uid],
      'birimler': varsayilanBirimler,
      'urunler': <Map<String, dynamic>>[],
      'kod': kod,
      'sayac': 0,
    });
    b.set(kodlar.doc(kod), {'firmaId': f.id});
    b.set(kullanicilar.doc(uid), {'ad': ad.trim(), 'firmaId': f.id},
        SetOptions(merge: true));
    await b.commit();
  }

  /// Davet koduyla firmaya katılır. Kod yanlışsa açıklayıcı hata atar.
  static Future<void> kodlaKatil(String uid, String ad, String kodYazi) async {
    final kod = kodYazi.trim().toUpperCase().replaceAll(' ', '');
    final k = await kodlar.doc(kod).get();
    final fid = k.data()?['firmaId'] as String?;
    if (!k.exists || fid == null) {
      throw 'Bu davet kodu bulunamadı. Kodu yöneticiden tekrar isteyin.';
    }
    await firmalar.doc(fid).update({
      'uyeler': FieldValue.arrayUnion([uid]),
      'katilKod': kod,
    });
    await kullanicilar
        .doc(uid)
        .set({'ad': ad.trim(), 'firmaId': fid}, SetOptions(merge: true));
  }

  static Future<void> firmadanAyril(String uid) =>
      kullanicilar.doc(uid).set({'firmaId': ''}, SetOptions(merge: true));

  /// Sipariş numarasını firma sayacından artırarak yeni sipariş ekler.
  static Future<int> siparisEkle(String fid, Map<String, dynamic> veri) {
    final fRef = firmalar.doc(fid);
    final sRef = siparisler(fid).doc();
    return _db.runTransaction<int>((tx) async {
      final f = await tx.get(fRef);
      final sayac = ((f.data()?['sayac'] as num?) ?? 0).toInt() + 1;
      tx.update(fRef, {'sayac': sayac});
      tx.set(sRef, {
        ...veri,
        'no': sayac,
        'sonIslem': {
          'tur': 'siparis',
          'by': FirebaseAuth.instance.currentUser?.uid ?? '',
          'tarih': veri['guncelleme'] ?? simdi,
        },
      });
      return sayac;
    });
  }

  /// [islem]: bildirimler için ne yapıldığı, örn. {'tur': 'tahsilat', 'tutar': 500}
  static Future<void> siparisGuncelle(
      String fid, String id, Map<String, dynamic> veri,
      {Map<String, dynamic>? islem}) {
    final t = simdi;
    return siparisler(fid).doc(id).update({
      ...veri,
      'guncelleme': t,
      'sonIslem': {
        'tur': 'duzeltme',
        ...?islem,
        'by': FirebaseAuth.instance.currentUser?.uid ?? '',
        'tarih': t,
      },
    });
  }

  static Future<void> siparisSil(String fid, String id) =>
      siparisler(fid).doc(id).delete();

  static Future<void> firmaGuncelle(String fid, Map<String, dynamic> veri) =>
      firmalar.doc(fid).update(veri);

  static Future<void> kodYenile(Firma f) async {
    final yeni = yeniKod();
    final b = _db.batch();
    b.set(kodlar.doc(yeni), {'firmaId': f.id});
    if (f.kod.isNotEmpty) b.delete(kodlar.doc(f.kod));
    b.update(firmalar.doc(f.id), {'kod': yeni});
    await b.commit();
  }
}

/// Bir firmanın canlı verisi: firma ayarları, siparişler ve kullanıcı adları.
class Durum extends ChangeNotifier {
  Durum({required this.fid, required this.uid}) {
    _fAbone = Veri.firmalar.doc(fid).snapshots().listen((s) {
      firma = s.exists ? Firma.fromMap(s.id, s.data()!) : null;
      firmaYok = !s.exists;
      firmaHata = null;
      notifyListeners();
    }, onError: (Object e) {
      firmaHata = e;
      notifyListeners();
    });
    _sAbone = Veri.siparisler(fid)
        .orderBy('guncelleme', descending: true)
        .limit(2000)
        .snapshots()
        .listen((s) {
      siparisler = s.docs.map((d) => Siparis.fromMap(d.id, d.data())).toList();
      yuklendi = true;
      siparisHata = null;
      notifyListeners();
      _isimleriGetir();
      if (!s.metadata.isFromCache) {
        Hareketler.isle(fid, uid, siparisler, isimBul: _isimBekle);
      }
    }, onError: (Object e) {
      siparisHata = e;
      yuklendi = true;
      notifyListeners();
    });
  }

  final String fid;
  final String uid;
  Firma? firma;
  bool firmaYok = false;
  Object? firmaHata;
  Object? siparisHata;
  List<Siparis> siparisler = const [];
  bool yuklendi = false;
  final Map<String, String> _isimler = {};
  final Set<String> _istenen = {};
  StreamSubscription? _fAbone;
  StreamSubscription? _sAbone;

  bool get uye => firma != null && firma!.uyeler.contains(uid);
  bool get yonetici => firma?.yonetici(uid) ?? false;

  List<Siparis> asamada(Asama a) =>
      siparisler.where((s) => s.asama == a).toList();
  int sayi(Asama a) => siparisler.where((s) => s.asama == a).length;

  double get ciro => siparisler.fold(0.0, (a, s) => a + s.toplam);
  double get tahsil => siparisler.fold(0.0, (a, s) => a + min(s.odenen, s.toplam));
  double get alacak => siparisler.fold(0.0, (a, s) => a + s.kalan);

  String isim(String id) {
    if (id.isEmpty) return '—';
    final v = _isimler[id];
    if (v != null) return v;
    _isimGetir([id]);
    return '…';
  }

  void _isimleriGetir() {
    final ids = <String>{...?firma?.uyeler};
    for (final s in siparisler) {
      ids.addAll([s.olusturan, s.fiyatlayan, s.teslimEden]);
      for (final t in s.tahsilatlar) {
        ids.add(t.by);
      }
    }
    _isimGetir(ids.where((e) => e.isNotEmpty));
  }

  Future<void> _isimGetir(Iterable<String> ids) async {
    final yeni = ids.where((i) => !_istenen.contains(i)).toList();
    if (yeni.isEmpty) return;
    _istenen.addAll(yeni);
    await Future.wait(yeni.map((i) async {
      try {
        final d = await Veri.kullanicilar.doc(i).get();
        final ad = (d.data()?['ad'] as String?)?.trim();
        _isimler[i] = (ad == null || ad.isEmpty) ? 'Kullanıcı' : ad;
      } catch (_) {
        _isimler[i] = 'Kullanıcı';
      }
    }));
    notifyListeners();
  }

  Future<String> _isimBekle(String id) async {
    final v = _isimler[id];
    if (v != null) return v;
    try {
      final d = await Veri.kullanicilar.doc(id).get();
      final ad = (d.data()?['ad'] as String?)?.trim();
      if (ad != null && ad.isNotEmpty) return _isimler[id] = ad;
    } catch (_) {}
    return 'Bir kullanıcı';
  }

  /// Ad değişince önbelleği tazeler.
  void isimTazele(String id) {
    _istenen.remove(id);
    _isimler.remove(id);
    _isimGetir([id]);
  }

  @override
  void dispose() {
    _fAbone?.cancel();
    _sAbone?.cancel();
    super.dispose();
  }
}

String hataYazisi(Object e) {
  if (e is String) return e;
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz yok.';
      case 'unavailable':
        return 'İnternet bağlantısı yok gibi görünüyor. Biraz sonra tekrar deneyin.';
      case 'invalid-email':
        return 'E-posta adresi geçersiz.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta ile zaten bir hesap var. Giriş yapın.';
      case 'weak-password':
        return 'Şifre çok zayıf, en az 6 karakter olmalı.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Biraz bekleyip tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
    }
    return e.message ?? e.code;
  }
  return '$e';
}
