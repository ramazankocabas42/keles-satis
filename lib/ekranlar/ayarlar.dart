import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bicim.dart';
import '../servis/guncelleme.dart';
import '../servis/veri.dart';
import '../tema.dart';
import 'formlar.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key, required this.durum});
  final Durum durum;

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  late final _firmaAd = TextEditingController(text: widget.durum.firma?.ad ?? '');
  late final _altyazi = TextEditingController(text: widget.durum.firma?.altyazi ?? '');
  late final _adim = TextEditingController(text: '');
  final _birim = TextEditingController();
  bool _adYuklendi = false;

  Durum get d => widget.durum;

  @override
  void initState() {
    super.initState();
    Veri.kullanicilar.doc(d.uid).get().then((s) {
      if (!mounted) return;
      _adim.text = (s.data()?['ad'] as String?) ?? '';
      setState(() => _adYuklendi = true);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _firmaAd.dispose();
    _altyazi.dispose();
    _adim.dispose();
    _birim.dispose();
    super.dispose();
  }

  Future<void> _calistir(Future<void> Function() is_, String basari) async {
    try {
      await is_();
      if (mounted) bildir(context, basari);
    } catch (e) {
      if (mounted) bildir(context, hataYazisi(e));
    }
  }

  Future<bool> _onay(String baslik, String yazi, String evet) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(baslik),
        content: Text(yazi),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(evet)),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListenableBuilder(
        listenable: d,
        builder: (context, _) {
          final f = d.firma!;
          final yon = d.yonetici;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 40),
            children: [
              if (!yon)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A2A10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA87A20)),
                  ),
                  child: const Text(
                      'Firma ayarlarını yalnızca yöneticiler değiştirebilir.',
                      style: TextStyle(color: Color(0xFFFFD98A))),
                ),

              // ---------------- Hesabım
              Panel(
                baslik: 'Hesabım',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _adim,
                      enabled: _adYuklendi,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Adınız'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OyunButonu(
                            yazi: 'Adı Kaydet',
                            renk: ButonRenk.sari,
                            onTap: () {
                              final a = _adim.text.trim();
                              if (a.length < 2) return;
                              _calistir(() async {
                                await Veri.adKaydet(d.uid, a);
                                d.isimTazele(d.uid);
                              }, 'Adınız kaydedildi');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OyunButonu(
                            yazi: 'Çıkış Yap',
                            renk: ButonRenk.gri,
                            onTap: () async {
                              Navigator.of(context).popUntil((r) => r.isFirst);
                              await FirebaseAuth.instance.signOut();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Guncelleme.buSurum > 0
                          ? 'Uygulama sürümü: ${Guncelleme.buSurum}'
                          : 'Uygulama sürümü: geliştirme',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Renk.soluk, fontSize: 12.5),
                    ),
                  ],
                ),
              ),

              // ---------------- Firma
              Panel(
                baslik: 'Firma',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _firmaAd,
                      enabled: yon,
                      maxLength: 24,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Firma adı (logo yazısı)'),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _altyazi,
                      enabled: yon,
                      maxLength: 28,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Alt şerit yazısı'),
                    ),
                    if (yon) ...[
                      const SizedBox(height: 4),
                      OyunButonu(
                        yazi: 'Kaydet',
                        renk: ButonRenk.sari,
                        onTap: () => _calistir(
                            () => Veri.firmaGuncelle(d.fid, {
                                  'ad': _firmaAd.text.trim().isEmpty
                                      ? f.ad
                                      : _firmaAd.text.trim(),
                                  'altyazi': _altyazi.text.trim(),
                                }),
                            'Firma bilgileri kaydedildi'),
                      ),
                    ],
                  ],
                ),
              ),

              // ---------------- Ürünler
              Panel(
                baslik: 'Hazır Ürünler',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (f.urunler.isEmpty)
                      const BosDurum(
                          em: '🧺',
                          yazi:
                              'Henüz hazır ürün yok. Ekleyince sipariş girerken tek dokunuşla seçilir.'),
                    for (var i = 0; i < f.urunler.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF2E3C66)))),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 44,
                                child: Text(f.urunler[i].em,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 28))),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.urunler[i].ad,
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w700)),
                                  Text(
                                    f.urunler[i].fiyat == null
                                        ? '${f.urunler[i].birim} · fiyat yok'
                                        : '${tl(f.urunler[i].fiyat!)} / ${f.urunler[i].birim}',
                                    style: const TextStyle(color: Renk.soluk, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            if (yon) ...[
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => urunDuzenle(context, d, i)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFFF8A8A)),
                                onPressed: () async {
                                  final u = f.urunler[i];
                                  if (!await _onay('${u.ad} silinsin mi?',
                                      'Eski siparişler etkilenmez.', 'Sil')) {
                                    return;
                                  }
                                  final l = [...f.urunler]..removeAt(i);
                                  await _calistir(
                                      () => Veri.firmaGuncelle(d.fid,
                                          {'urunler': l.map((e) => e.toMap()).toList()}),
                                      'Ürün silindi');
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (yon) ...[
                      const SizedBox(height: 12),
                      OyunButonu(
                          yazi: '＋ Ürün Ekle',
                          renk: ButonRenk.yesil,
                          onTap: () => urunDuzenle(context, d, -1)),
                    ],
                  ],
                ),
              ),

              // ---------------- Birimler
              Panel(
                baslik: 'Birimler',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final b in f.birimListesi)
                          Chip(
                            label: Text(b),
                            backgroundColor: const Color(0xFF2C3A62),
                            onDeleted: !yon || f.birimListesi.length <= 1
                                ? null
                                : () => _calistir(
                                    () => Veri.firmaGuncelle(d.fid, {
                                          'birimler': [...f.birimListesi]..remove(b)
                                        }),
                                    '$b kaldırıldı'),
                          ),
                      ],
                    ),
                    if (yon) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _birim,
                              maxLength: 12,
                              decoration: const InputDecoration(
                                  hintText: 'Yeni birim (örn. bağ)', counterText: ''),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 96,
                            child: OyunButonu(
                              yazi: 'Ekle',
                              renk: ButonRenk.mavi,
                              yukseklik: 50,
                              onTap: () {
                                final b = _birim.text.trim();
                                if (b.isEmpty) return;
                                if (f.birimListesi.contains(b)) {
                                  bildir(context, 'Bu birim zaten var');
                                  return;
                                }
                                _birim.clear();
                                _calistir(
                                    () => Veri.firmaGuncelle(d.fid,
                                        {'birimler': [...f.birimListesi, b]}),
                                    '$b eklendi');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ---------------- Ekip
              Panel(
                baslik: 'Ekip',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (yon) ...[
                      const Text('Davet kodu',
                          style: TextStyle(color: Renk.soluk, fontSize: 13.5)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Renk.girdi,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Renk.altin2, width: 2),
                              ),
                              child: SelectableText(f.kod,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      letterSpacing: 4,
                                      fontWeight: FontWeight.w800,
                                      color: Renk.altin)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'Kopyala',
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      '${f.ad} satış uygulamasına katılmak için davet kodu: ${f.kod}'));
                              if (context.mounted) bildir(context, 'Kod kopyalandı');
                            },
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Yeni kod',
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              if (!await _onay('Kod yenilensin mi?',
                                  'Eski kod artık çalışmaz. Ekipteki kişiler etkilenmez.',
                                  'Yenile')) {
                                return;
                              }
                              await _calistir(() => Veri.kodYenile(f), 'Yeni kod oluşturuldu');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Çalışan uygulamayı kurup hesap açar, "Kodla katıl" der ve bu kodu yazar.',
                        style: TextStyle(color: Renk.soluk, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                    ],
                    for (final u in f.uyeler)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF2E3C66)))),
                        child: Row(
                          children: [
                            const Text('👤', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.isim(u) + (u == d.uid ? ' (siz)' : ''),
                                      style: const TextStyle(
                                          fontSize: 15.5, fontWeight: FontWeight.w600)),
                                  Text(
                                    u == f.sahip
                                        ? 'Firma sahibi'
                                        : f.yonetici(u)
                                            ? 'Yönetici'
                                            : 'Ekip üyesi',
                                    style: const TextStyle(color: Renk.soluk, fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            if (yon && u != f.sahip && u != d.uid)
                              PopupMenuButton<String>(
                                color: Renk.kart2,
                                onSelected: (v) async {
                                  if (v == 'yon') {
                                    await _calistir(
                                        () => Veri.firmaGuncelle(d.fid, {
                                              'yoneticiler': f.yonetici(u)
                                                  ? (List<String>.of(f.yoneticiler)..remove(u))
                                                  : [...f.yoneticiler, u]
                                            }),
                                        'Yetki güncellendi');
                                  } else if (v == 'cik') {
                                    if (!await _onay('${d.isim(u)} çıkarılsın mı?',
                                        'Bu kişi artık firmanın siparişlerini göremez.', 'Çıkar')) {
                                      return;
                                    }
                                    await _calistir(
                                        () => Veri.firmaGuncelle(d.fid, {
                                              'uyeler': List<String>.of(f.uyeler)..remove(u),
                                              'yoneticiler': List<String>.of(f.yoneticiler)..remove(u),
                                            }),
                                        'Ekipten çıkarıldı');
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                      value: 'yon',
                                      child: Text(f.yonetici(u)
                                          ? 'Yöneticilikten al'
                                          : 'Yönetici yap')),
                                  const PopupMenuItem(
                                      value: 'cik', child: Text('Ekipten çıkar')),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
