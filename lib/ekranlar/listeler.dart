import 'package:flutter/material.dart';

import '../bicim.dart';
import '../modeller.dart';
import '../servis/veri.dart';
import '../tema.dart';
import 'formlar.dart';

/// Fotoğraftaki mağaza kartlarına benzeyen sipariş kartı.
class SiparisKarti extends StatelessWidget {
  const SiparisKarti({super.key, required this.durum, required this.s});
  final Durum durum;
  final Siparis s;

  @override
  Widget build(BuildContext context) {
    final a = s.asama;
    final b = asamaBilgi[a]!;
    final fiyatli = s.fiyat != null;
    final em = durum.firma?.urunBul(s.urun)?.em ?? b.em;
    final (Color er, Color ei) = switch (a) {
      Asama.fiyat => (Renk.kirmizi, Colors.white),
      Asama.teslim => (Renk.altin, const Color(0xFF5A3200)),
      Asama.tahsilat => (Renk.mavi, Colors.white),
      Asama.tamam => (Renk.yesil, Colors.white),
    };

    Widget? eylem;
    switch (a) {
      case Asama.fiyat:
        eylem = OyunButonu(
            yazi: '🏷️ Fiyat Gir',
            renk: ButonRenk.sari,
            onTap: () => fiyatGir(context, durum, s));
      case Asama.teslim:
        eylem = OyunButonu(
            yazi: '🚚 Teslim Edildi',
            renk: ButonRenk.yesil,
            onTap: () => teslimEt(context, durum, s));
      case Asama.tahsilat:
        eylem = OyunButonu(
            yazi: '💰 Tahsilat Gir',
            renk: ButonRenk.mavi,
            onTap: () => tahsilEt(context, durum, s));
      case Asama.tamam:
        eylem = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => detayGoster(context, durum, s),
              child: Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF232F52), Color(0xFF1E2846)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Renk.cizgi, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 70,
                      child: Column(
                        children: [
                          Text(em,
                              style: const TextStyle(fontSize: 46, shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 4))
                              ])),
                          Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              color: const Color(0xFF3E4F7E)),
                          Text('#${s.no}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note, size: 20),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(s.musteri,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const Text('📍', style: TextStyle(fontSize: 13)),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 90),
                                child: Text(durum.isim(s.olusturan),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Renk.soluk, fontSize: 12.5)),
                              ),
                            ],
                          ),
                          Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: Renk.cizgi),
                          Row(
                            children: [
                              Expanded(child: Cip(ust: 'Ürün', deger: s.urun)),
                              const SizedBox(width: 5),
                              Expanded(
                                  child: Cip(
                                      ust: 'Miktar',
                                      deger: '${sayi(s.miktar)} ${s.birim}')),
                              const SizedBox(width: 5),
                              Expanded(
                                  child: Cip(
                                      ust: 'Birim fiyat',
                                      deger: fiyatli ? tl(s.fiyat!) : '—',
                                      durum: fiyatli ? null : false)),
                              const SizedBox(width: 5),
                              Expanded(
                                  child: Cip(
                                      ust: a == Asama.tahsilat ? 'Kalan' : 'Toplam',
                                      deger: !fiyatli
                                          ? '—'
                                          : tl(a == Asama.tahsilat ? s.kalan : s.toplam),
                                      durum: a == Asama.tamam ? true : null)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              Etiket(isaret: '🕒', yazi: once(s.sonIslem)),
                              Etiket(
                                  isaret: b.isaret,
                                  yazi: b.ad,
                                  renk: er,
                                  isaretRenk: ei),
                              if (s.odenen > 0 && a != Asama.tamam)
                                Etiket(
                                    isaret: '₺',
                                    yazi: '${kisaTl(s.odenen)} alındı',
                                    renk: Renk.yesil,
                                    isaretRenk: Colors.white),
                            ],
                          ),
                          if (eylem != null) ...[
                            const SizedBox(height: 10),
                            eylem,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (a != Asama.tamam)
            const Positioned(top: -5, right: -5, child: KirmiziNokta()),
        ],
      ),
    );
  }
}

/// Arama kutulu sipariş listesi (sekme içinde ya da ayrı ekranda).
class SiparisListesi extends StatefulWidget {
  const SiparisListesi({
    super.key,
    required this.durum,
    required this.baslik,
    required this.filtre,
    required this.bosEm,
    required this.bosYazi,
    this.ozet,
    this.asamaSecimi = false,
    this.baslikGoster = true,
    this.ilkArama = '',
  });

  final Durum durum;
  final String baslik;
  final bool Function(Siparis) filtre;
  final String bosEm;
  final String bosYazi;
  final String Function(List<Siparis>)? ozet;
  final bool asamaSecimi;
  final bool baslikGoster;
  final String ilkArama;

  @override
  State<SiparisListesi> createState() => _SiparisListesiState();
}

class _SiparisListesiState extends State<SiparisListesi> {
  late final _ara = TextEditingController(text: widget.ilkArama);
  Asama? _asama;

  @override
  void dispose() {
    _ara.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.durum,
      builder: (context, _) {
        final d = widget.durum;
        final q = _ara.text.trim().toLowerCase();
        final l = d.siparisler
            .where(widget.filtre)
            .where((s) => _asama == null || s.asama == _asama)
            .where((s) =>
                q.isEmpty ||
                '${s.musteri} ${s.urun} ${s.no} ${s.not}'.toLowerCase().contains(q))
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          children: [
            if (widget.baslikGoster)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                child: Text(widget.baslik,
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
              ),
            if (widget.asamaSecimi)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final (Asama? k, String ad) in [
                      (null, 'Hepsi'),
                      (Asama.fiyat, 'Fiyat'),
                      (Asama.teslim, 'Teslim'),
                      (Asama.tahsilat, 'Tahsilat'),
                      (Asama.tamam, 'Tamam'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(ad),
                          selected: _asama == k,
                          selectedColor: Renk.altin,
                          labelStyle: TextStyle(
                              color: _asama == k ? const Color(0xFF4A2A00) : Renk.yazi,
                              fontWeight: FontWeight.w600),
                          backgroundColor: const Color(0xFF26335B),
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _asama = k),
                        ),
                      ),
                  ],
                ),
              ),
            if (widget.asamaSecimi) const SizedBox(height: 10),
            TextField(
              controller: _ara,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Müşteri, ürün veya no ara…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ara.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_ara.clear)),
              ),
            ),
            const SizedBox(height: 10),
            if (widget.ozet != null && l.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(widget.ozet!(l),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Renk.soluk, fontSize: 14)),
              ),
            if (d.siparisHata != null)
              BosDurum(em: '⚠️', yazi: hataYazisi(d.siparisHata!))
            else if (!d.yuklendi)
              const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator(color: Renk.altin)))
            else if (l.isEmpty)
              BosDurum(em: widget.bosEm, yazi: widget.bosYazi)
            else
              for (final s in l) SiparisKarti(durum: d, s: s),
          ],
        );
      },
    );
  }
}

class SiparisListesiEkrani extends StatelessWidget {
  const SiparisListesiEkrani({
    super.key,
    required this.durum,
    required this.baslik,
    required this.filtre,
    required this.bosEm,
    required this.bosYazi,
    this.ozet,
    this.asamaSecimi = false,
    this.ilkArama = '',
  });

  final Durum durum;
  final String baslik;
  final bool Function(Siparis) filtre;
  final String bosEm;
  final String bosYazi;
  final String Function(List<Siparis>)? ozet;
  final bool asamaSecimi;
  final String ilkArama;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(baslik)),
        body: SiparisListesi(
          durum: durum,
          baslik: baslik,
          filtre: filtre,
          bosEm: bosEm,
          bosYazi: bosYazi,
          ozet: ozet,
          asamaSecimi: asamaSecimi,
          baslikGoster: false,
          ilkArama: ilkArama,
        ),
      );
}
