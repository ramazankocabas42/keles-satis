import 'package:flutter/material.dart';

import '../bicim.dart';
import '../modeller.dart';
import '../servis/veri.dart';
import '../tema.dart';

const yontemler = ['Nakit', 'Havale/EFT', 'Kredi Kartı', 'Çek', 'Senet'];

/// Yazma işlemini çalıştırır; hata olursa gösterir. Başarılıysa true.
Future<bool> _calistir(BuildContext context, Future<void> Function() is_,
    {String? basari}) async {
  try {
    await is_();
    if (basari != null && context.mounted) bildir(context, basari);
    return true;
  } catch (e) {
    if (context.mounted) bildir(context, hataYazisi(e));
    return false;
  }
}

Widget _ikili(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 14, child: a),
        const SizedBox(width: 10),
        Expanded(flex: 10, child: b),
      ],
    );

Widget _birimSecici(
        List<String> birimler, String secili, ValueChanged<String> degisti) =>
    DropdownButtonFormField<String>(
      initialValue: birimler.contains(secili) ? secili : birimler.first,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Birim'),
      dropdownColor: Renk.kart2,
      items: [
        for (final b in birimler) DropdownMenuItem(value: b, child: Text(b)),
      ],
      onChanged: (v) => v == null ? null : degisti(v),
    );

Widget _butonlar(BuildContext context,
        {required String yazi,
        required ButonRenk renk,
        required bool mesgul,
        required VoidCallback onTap}) =>
    Row(
      children: [
        Expanded(
            child: OyunButonu(
                yazi: 'Vazgeç',
                renk: ButonRenk.gri,
                onTap: mesgul ? null : () => Navigator.pop(context))),
        const SizedBox(width: 10),
        Expanded(
            flex: 2,
            child: OyunButonu(
                yazi: yazi, renk: renk, mesgul: mesgul, onTap: onTap)),
      ],
    );

// ---------------------------------------------------------------- Yeni sipariş

Future<void> yeniSiparis(BuildContext context, Durum d) {
  final f = d.firma!;
  final musteriler = {for (final s in d.siparisler) s.musteri.trim()}
    ..removeWhere((e) => e.isEmpty);
  final urunAdlari = {
    ...f.urunler.map((u) => u.ad),
    for (final s in d.siparisler) s.urun.trim()
  }..removeWhere((e) => e.isEmpty);

  return altSayfa(
    context,
    baslik: '🛒 Yeni Sipariş',
    aciklama: 'Önce siparişi girin; fiyat bir sonraki adımda yazılır.',
    builder: (ctx) {
      final musteri = TextEditingController();
      final urun = TextEditingController();
      final miktar = TextEditingController();
      final not = TextEditingController();
      final fiyat = TextEditingController();
      final musteriOdak = FocusNode();
      final urunOdak = FocusNode();
      var birim = f.birimListesi.first;
      var birimler = [...f.birimListesi];
      var mesgul = false;
      var birimAnahtar = 0;

      return StatefulBuilder(builder: (ctx, set) {
        Urun? secili = f.urunBul(urun.text);

        void urunSec(Urun u) {
          set(() {
            urun.text = u.ad;
            if (u.birim.isNotEmpty) {
              if (!birimler.contains(u.birim)) birimler = [...birimler, u.birim];
              birim = u.birim;
              birimAnahtar++;
            }
            if (u.fiyat != null && fiyat.text.isEmpty) fiyat.text = girdi(u.fiyat);
          });
        }

        Future<void> kaydet() async {
          final m = sayiOku(miktar.text);
          final fy = sayiOku(fiyat.text);
          if (musteri.text.trim().isEmpty || urun.text.trim().isEmpty) {
            bildir(ctx, 'Müşteri ve ürünü yazın.');
            return;
          }
          if (m == null || m <= 0) {
            bildir(ctx, 'Geçerli bir miktar girin.');
            return;
          }
          if (fiyat.text.trim().isNotEmpty && (fy == null || fy < 0)) {
            bildir(ctx, 'Fiyat geçersiz.');
            return;
          }
          set(() => mesgul = true);
          final simdi = Veri.simdi;
          int? no;
          final ok = await _calistir(ctx, () async {
            no = await Veri.siparisEkle(d.fid, {
              'musteri': musteri.text.trim(),
              'urun': urun.text.trim(),
              'miktar': m,
              'birim': birim,
              'not': not.text.trim(),
              'olusturan': d.uid,
              'olusturma': simdi,
              'guncelleme': simdi,
              'fiyat': fy,
              'fiyatlayan': fy != null ? d.uid : '',
              'fiyatTarih': fy != null ? simdi : 0,
              'teslim': false,
              'teslimEden': '',
              'teslimTarih': 0,
              'teslimNot': '',
              'tahsilatlar': <Map<String, dynamic>>[],
            });
          });
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.pop(ctx);
            bildir(context, '#$no sipariş kaydedildi');
          } else {
            set(() => mesgul = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OneriliAlan(
              controller: musteri,
              focusNode: musteriOdak,
              secenekler: musteriler,
              etiket: 'Müşteri',
              ipucu: 'Firma veya kişi adı',
              buyukHarf: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            if (f.urunler.isNotEmpty) ...[
              const Text('Ürün seçin', style: TextStyle(color: Renk.soluk)),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final u in f.urunler)
                    _UrunKaresi(
                        urun: u,
                        secili: identical(secili, u),
                        onTap: () => urunSec(u)),
                ],
              ),
              const SizedBox(height: 12),
            ],
            OneriliAlan(
              controller: urun,
              focusNode: urunOdak,
              secenekler: urunAdlari,
              etiket: f.urunler.isEmpty ? 'Ürün' : 'veya ürün adı yazın',
              ipucu: 'Örn. Domates',
              onDegisti: (_) => set(() {}),
              onSecildi: (v) {
                final u = f.urunBul(v);
                if (u != null) {
                  urunSec(u);
                } else {
                  set(() {});
                }
              },
            ),
            const SizedBox(height: 12),
            _ikili(
              TextField(
                controller: miktar,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Miktar', hintText: '0'),
              ),
              KeyedSubtree(
                key: ValueKey(birimAnahtar),
                child: _birimSecici(birimler, birim, (v) => birim = v),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: not,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Not (isteğe bağlı)',
                  hintText: 'Teslim adresi, tarih vb.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fiyat,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Birim fiyat ₺ (biliyorsanız)',
                  hintText: 'Boş bırakılabilir'),
            ),
            const SizedBox(height: 16),
            _butonlar(ctx,
                yazi: 'Kaydet',
                renk: ButonRenk.yesil,
                mesgul: mesgul,
                onTap: kaydet),
          ],
        );
      });
    },
  );
}

class _UrunKaresi extends StatelessWidget {
  const _UrunKaresi(
      {required this.urun, required this.secili, required this.onTap});
  final Urun urun;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: secili ? const Color(0xFF4A2236) : const Color(0xFF2C3A62),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: secili ? Renk.kirmizi : const Color(0xFF56688F), width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(urun.em, style: const TextStyle(fontSize: 28)),
                Text(urun.ad,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5)),
              ],
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------- Fiyat

Future<void> fiyatGir(BuildContext context, Durum d, Siparis s) {
  return altSayfa(
    context,
    baslik: '🏷️ Fiyat Gir · #${s.no}',
    aciklama: '${s.musteri} — ${s.urun}',
    builder: (ctx) {
      final miktar = TextEditingController(text: girdi(s.miktar));
      final varsayilan = s.fiyat ?? d.firma?.urunBul(s.urun)?.fiyat;
      final fiyat = TextEditingController(text: girdi(varsayilan));
      final birimler = {...d.firma!.birimListesi, if (s.birim.isNotEmpty) s.birim}.toList();
      var birim = s.birim.isEmpty ? birimler.first : s.birim;
      var mesgul = false;
      return StatefulBuilder(builder: (ctx, set) {
        final m = sayiOku(miktar.text), p = sayiOku(fiyat.text);
        Future<void> kaydet() async {
          if (m == null || m <= 0 || p == null || p < 0) {
            bildir(ctx, 'Miktar ve fiyatı kontrol edin.');
            return;
          }
          set(() => mesgul = true);
          final ok = await _calistir(
              ctx,
              () => Veri.siparisGuncelle(d.fid, s.id, {
                    'miktar': m,
                    'birim': birim,
                    'fiyat': p,
                    'fiyatlayan': d.uid,
                    'fiyatTarih': Veri.simdi,
                  }));
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.pop(ctx);
            bildir(context, '#${s.no} fiyatlandı: ${tl(m * p)}');
          } else {
            set(() => mesgul = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ikili(
              TextField(
                controller: miktar,
                onChanged: (_) => set(() {}),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Miktar (kesin)'),
              ),
              _birimSecici(birimler, birim, (v) => birim = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fiyat,
              autofocus: s.fiyat == null,
              onChanged: (_) => set(() {}),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Birim fiyat (₺)', hintText: '0,00'),
            ),
            const SizedBox(height: 12),
            ToplamKutusu(
                etiket: 'Toplam tutar',
                deger: (m != null && p != null) ? tl(m * p) : '—'),
            _butonlar(ctx,
                yazi: 'Fiyatı Kaydet',
                renk: ButonRenk.sari,
                mesgul: mesgul,
                onTap: kaydet),
          ],
        );
      });
    },
  );
}

// ---------------------------------------------------------------- Teslim

Future<void> teslimEt(BuildContext context, Durum d, Siparis s) {
  return altSayfa(
    context,
    baslik: '🚚 Teslim · #${s.no}',
    aciklama:
        '${s.musteri} — ${sayi(s.miktar)} ${s.birim} ${s.urun} · ${tl(s.toplam)}',
    builder: (ctx) {
      final not = TextEditingController();
      final tutar = TextEditingController();
      var yontem = yontemler.first;
      var mesgul = false;
      return StatefulBuilder(builder: (ctx, set) {
        Future<void> kaydet() async {
          final ham = tutar.text.trim();
          final t = ham.isEmpty ? 0.0 : sayiOku(ham);
          if (t == null || t < 0) {
            bildir(ctx, 'Tutar geçersiz.');
            return;
          }
          set(() => mesgul = true);
          final simdi = Veri.simdi;
          final ok = await _calistir(
              ctx,
              () => Veri.siparisGuncelle(d.fid, s.id, {
                    'teslim': true,
                    'teslimEden': d.uid,
                    'teslimTarih': simdi,
                    'teslimNot': not.text.trim(),
                    'tahsilatlar': [
                      ...s.tahsilatlar.map((e) => e.toMap()),
                      if (t > 0)
                        Tahsilat(tutar: t, yontem: yontem, tarih: simdi, by: d.uid)
                            .toMap(),
                    ],
                  }));
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.pop(ctx);
            bildir(context, '#${s.no} teslim edildi');
          } else {
            set(() => mesgul = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: not,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Teslim notu (isteğe bağlı)',
                  hintText: 'Teslim alan, irsaliye no vb.'),
            ),
            const SizedBox(height: 12),
            _ikili(
              TextField(
                controller: tutar,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Teslimde alınan ₺', hintText: 'Yoksa boş'),
              ),
              DropdownButtonFormField<String>(
                initialValue: yontem,
                isExpanded: true,
                dropdownColor: Renk.kart2,
                decoration: const InputDecoration(labelText: 'Yöntem'),
                items: [
                  for (final y in yontemler) DropdownMenuItem(value: y, child: Text(y))
                ],
                onChanged: (v) => yontem = v ?? yontem,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                label: Text('Tamamı alındı (${tl(s.kalan)})'),
                backgroundColor: const Color(0xFF2C3A62),
                onPressed: () => set(() => tutar.text = girdi(s.kalan)),
              ),
            ),
            const SizedBox(height: 14),
            _butonlar(ctx,
                yazi: '✓ Teslim Edildi',
                renk: ButonRenk.yesil,
                mesgul: mesgul,
                onTap: kaydet),
          ],
        );
      });
    },
  );
}

// ---------------------------------------------------------------- Tahsilat

Future<void> tahsilEt(BuildContext context, Durum d, Siparis s) {
  final kalan = s.kalan;
  return altSayfa(
    context,
    baslik: '💰 Tahsilat · #${s.no}',
    aciklama: '${s.musteri} — Toplam ${tl(s.toplam)} · Alınan ${tl(s.odenen)}',
    builder: (ctx) {
      final tutar = TextEditingController(text: girdi(kalan));
      var yontem = yontemler.first;
      var mesgul = false;
      var fazlaOnay = false;
      return StatefulBuilder(builder: (ctx, set) {
        Future<void> kaydet() async {
          final t = sayiOku(tutar.text);
          if (t == null || t <= 0) {
            bildir(ctx, 'Tutar geçersiz.');
            return;
          }
          if (t > kalan + 0.009 && !fazlaOnay) {
            set(() => fazlaOnay = true);
            bildir(ctx, 'Tutar kalandan fazla. Yine de kaydetmek için tekrar basın.');
            return;
          }
          set(() => mesgul = true);
          final ok = await _calistir(
              ctx,
              () => Veri.siparisGuncelle(d.fid, s.id, {
                    'tahsilatlar': [
                      ...s.tahsilatlar.map((e) => e.toMap()),
                      Tahsilat(
                              tutar: t,
                              yontem: yontem,
                              tarih: Veri.simdi,
                              by: d.uid)
                          .toMap(),
                    ],
                  }));
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.pop(ctx);
            bildir(
                context,
                t >= kalan
                    ? '#${s.no} tamamen tahsil edildi 🎉'
                    : '${tl(t)} tahsil edildi');
          } else {
            set(() => mesgul = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToplamKutusu(etiket: 'Kalan alacak', deger: tl(kalan)),
            _ikili(
              TextField(
                controller: tutar,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Tahsil edilen ₺'),
              ),
              DropdownButtonFormField<String>(
                initialValue: yontem,
                isExpanded: true,
                dropdownColor: Renk.kart2,
                decoration: const InputDecoration(labelText: 'Yöntem'),
                items: [
                  for (final y in yontemler) DropdownMenuItem(value: y, child: Text(y))
                ],
                onChanged: (v) => yontem = v ?? yontem,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                    label: const Text('Tamamı'),
                    backgroundColor: const Color(0xFF2C3A62),
                    onPressed: () => set(() => tutar.text = girdi(kalan))),
                ActionChip(
                    label: const Text('Yarısı'),
                    backgroundColor: const Color(0xFF2C3A62),
                    onPressed: () => set(() =>
                        tutar.text = girdi((kalan / 2 * 100).round() / 100))),
              ],
            ),
            const SizedBox(height: 14),
            _butonlar(ctx,
                yazi: 'Tahsil Et',
                renk: ButonRenk.mavi,
                mesgul: mesgul,
                onTap: kaydet),
          ],
        );
      });
    },
  );
}

// ---------------------------------------------------------------- Detay

Future<void> detayGoster(BuildContext context, Durum d, Siparis s0) {
  return altSayfa(
    context,
    baslik: '${asamaBilgi[s0.asama]!.em} Sipariş #${s0.no}',
    aciklama: '${s0.musteri} · ${s0.urun}',
    builder: (ctx) => ListenableBuilder(
      listenable: d,
      builder: (ctx, _) {
        final s = d.siparisler.firstWhere((x) => x.id == s0.id,
            orElse: () => s0);
        final silinebilir = d.yonetici || s.olusturan == d.uid;
        Widget satir(String em, String yazi, String kim, int t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(em, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(yazi, style: const TextStyle(fontSize: 15)),
                        Text('${d.isim(kim)} · ${tarihSaat(t)}',
                            style: const TextStyle(color: Renk.soluk, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
            );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (s.not.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF1D2A4C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3E4F7E))),
                child: Text('📝 ${s.not}'),
              ),
            Row(
              children: [
                Expanded(
                    child: Cip(
                        ust: 'Toplam',
                        deger: s.fiyat == null ? '—' : tl(s.toplam))),
                const SizedBox(width: 6),
                Expanded(child: Cip(ust: 'Alınan', deger: tl(s.odenen), durum: true)),
                const SizedBox(width: 6),
                Expanded(
                    child: Cip(
                        ust: 'Kalan',
                        deger: tl(s.kalan),
                        durum: s.kalan > 0 ? false : null)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFF3E4F7E), width: 3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  satir('🛒', 'Sipariş girildi — ${sayi(s.miktar)} ${s.birim}',
                      s.olusturan, s.olusturma),
                  if (s.fiyat != null)
                    satir('🏷️', 'Fiyat: ${tl(s.fiyat!)} / ${s.birim} = ${tl(s.toplam)}',
                        s.fiyatlayan, s.fiyatTarih),
                  if (s.teslim)
                    satir(
                        '🚚',
                        'Teslim edildi${s.teslimNot.isEmpty ? '' : ' — ${s.teslimNot}'}',
                        s.teslimEden,
                        s.teslimTarih),
                  for (final t in s.tahsilatlar)
                    satir('💰', '${tl(t.tutar)} tahsil edildi (${t.yontem})', t.by,
                        t.tarih),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (s.fiyat != null)
                  _kucuk('🏷️ Fiyatı düzelt', ButonRenk.sari, () {
                    Navigator.pop(ctx);
                    fiyatGir(context, d, s);
                  }),
                if (s.asama == Asama.teslim)
                  _kucuk('🚚 Teslim edildi', ButonRenk.yesil, () {
                    Navigator.pop(ctx);
                    teslimEt(context, d, s);
                  }),
                if (s.fiyat != null && s.kalan > 0)
                  _kucuk('💰 Tahsilat gir', ButonRenk.mavi, () {
                    Navigator.pop(ctx);
                    tahsilEt(context, d, s);
                  }),
                if (s.teslim)
                  _kucuk('↩️ Teslimi geri al', ButonRenk.gri, () async {
                    final ok = await _calistir(
                        ctx,
                        () => Veri.siparisGuncelle(d.fid, s.id, {
                              'teslim': false,
                              'teslimEden': '',
                              'teslimTarih': 0,
                            }),
                        basari: 'Teslim geri alındı');
                    if (ok && ctx.mounted) Navigator.pop(ctx);
                  }),
                if (silinebilir)
                  _kucuk('🗑 Sil', ButonRenk.kirmizi, () async {
                    final evet = await showDialog<bool>(
                      context: ctx,
                      builder: (c) => AlertDialog(
                        title: Text('#${s.no} silinsin mi?'),
                        content: const Text('Bu sipariş ve tahsilat kayıtları silinir.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Vazgeç')),
                          FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Renk.kirmizi),
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Sil')),
                        ],
                      ),
                    );
                    if (evet != true || !ctx.mounted) return;
                    final ok = await _calistir(
                        ctx, () => Veri.siparisSil(d.fid, s.id));
                    if (ok && ctx.mounted) {
                      Navigator.pop(ctx);
                      bildir(context, '#${s.no} silindi');
                    }
                  }),
              ],
            ),
            const SizedBox(height: 12),
            OyunButonu(
                yazi: 'Kapat',
                renk: ButonRenk.gri,
                onTap: () => Navigator.pop(ctx)),
          ],
        );
      },
    ),
  );
}

Widget _kucuk(String yazi, ButonRenk r, VoidCallback onTap) => SizedBox(
    width: 160,
    child: OyunButonu(yazi: yazi, renk: r, yukseklik: 42, onTap: onTap));

// ---------------------------------------------------------------- Ürün düzenle

const simgeler = [
  '🍅', '🥒', '🌶️', '🫑', '🍆', '🥔', '🧅', '🧄', '🥕', '🌽', '🥬', '🥦',
  '🍉', '🍈', '🍓', '🍇', '🍋', '🍊', '🍎', '🍐', '🍑', '🍒', '🫘', '🌾',
  '🌻', '🥜', '🥚', '🥛', '🧀', '🐄', '🐑', '🐔', '🍯', '🫒', '🪵', '📦',
];

Future<void> urunDuzenle(BuildContext context, Durum d, int index) {
  final f = d.firma!;
  final eski = index >= 0 ? f.urunler[index] : null;
  return altSayfa(
    context,
    baslik: eski == null ? '＋ Yeni Ürün' : '✏️ Ürünü Düzenle',
    aciklama: 'Sipariş girerken bu ürün hazır kutucuk olarak çıkar.',
    builder: (ctx) {
      final ad = TextEditingController(text: eski?.ad ?? '');
      final fiyat = TextEditingController(text: girdi(eski?.fiyat));
      var em = eski?.em ?? '🍅';
      var birim = eski?.birim ?? f.birimListesi.first;
      var mesgul = false;
      return StatefulBuilder(builder: (ctx, set) {
        Future<void> kaydet() async {
          final a = ad.text.trim();
          if (a.isEmpty) {
            bildir(ctx, 'Ürün adını yazın.');
            return;
          }
          final ham = fiyat.text.trim();
          final p = ham.isEmpty ? null : sayiOku(ham);
          if (ham.isNotEmpty && (p == null || p < 0)) {
            bildir(ctx, 'Fiyat geçersiz.');
            return;
          }
          set(() => mesgul = true);
          final yeni = Urun(ad: a, birim: birim, fiyat: p, em: em);
          final liste = [...f.urunler];
          if (index >= 0) {
            liste[index] = yeni;
          } else {
            liste.add(yeni);
          }
          final ok = await _calistir(
              ctx,
              () => Veri.firmaGuncelle(
                  d.fid, {'urunler': liste.map((u) => u.toMap()).toList()}));
          if (!ctx.mounted) return;
          if (ok) {
            Navigator.pop(ctx);
          } else {
            set(() => mesgul = false);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Simge', style: TextStyle(color: Renk.soluk)),
            const SizedBox(height: 6),
            GridView.count(
              crossAxisCount: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (final e in simgeler)
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => set(() => em = e),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3A62),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: e == em ? Renk.altin : Colors.transparent,
                            width: 2),
                      ),
                      child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 20))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ad,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Ürün adı'),
            ),
            const SizedBox(height: 12),
            _ikili(
              TextField(
                controller: fiyat,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Varsayılan fiyat ₺', hintText: 'İsteğe bağlı'),
              ),
              _birimSecici(f.birimListesi, birim, (v) => birim = v),
            ),
            const SizedBox(height: 16),
            _butonlar(ctx,
                yazi: 'Kaydet',
                renk: ButonRenk.yesil,
                mesgul: mesgul,
                onTap: kaydet),
          ],
        );
      });
    },
  );
}
