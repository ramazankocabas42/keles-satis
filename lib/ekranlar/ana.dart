import 'package:flutter/material.dart';

import '../bicim.dart';
import '../modeller.dart';
import '../servis/guncelleme.dart';
import '../servis/veri.dart';
import '../tema.dart';
import 'ayarlar.dart';
import 'formlar.dart';
import 'listeler.dart';
import 'ozet.dart';

/// Üst bilgi + sayaçlar + sekmeler + alt menü.
class AnaKabuk extends StatefulWidget {
  const AnaKabuk({super.key, required this.durum});
  final Durum durum;

  @override
  State<AnaKabuk> createState() => _AnaKabukState();
}

class _AnaKabukState extends State<AnaKabuk> {
  int _sekme = 0; // 0 ana, 1 fiyat, 2 teslim, 3 tahsilat

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Guncelleme.kontrolEt(context);
    });
  }

  void _git(Widget ekran) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ekran));

  void sekmeyeGit(int i) => setState(() => _sekme = i);

  @override
  Widget build(BuildContext context) {
    final d = widget.durum;
    return ListenableBuilder(
      listenable: d,
      builder: (context, _) {
        final f = d.firma!;
        final nF = d.sayi(Asama.fiyat), nT = d.sayi(Asama.teslim), nC = d.sayi(Asama.tahsilat);
        Widget govde;
        switch (_sekme) {
          case 1:
            govde = SiparisListesi(
                key: const ValueKey('fiyat'),
                durum: d,
                baslik: 'Fiyat Bekleyenler',
                filtre: (s) => s.asama == Asama.fiyat,
                bosEm: '🎉',
                bosYazi: 'Fiyatı girilmemiş sipariş yok.');
          case 2:
            govde = SiparisListesi(
                key: const ValueKey('teslim'),
                durum: d,
                baslik: 'Teslim Bekleyenler',
                filtre: (s) => s.asama == Asama.teslim,
                bosEm: '📦',
                bosYazi: 'Teslim edilecek sipariş yok.',
                ozet: (l) =>
                    'Toplam ${tl(l.fold(0.0, (a, s) => a + s.toplam))} değerinde ${l.length} sipariş');
          case 3:
            govde = SiparisListesi(
                key: const ValueKey('tahsil'),
                durum: d,
                baslik: 'Tahsilat Bekleyenler',
                filtre: (s) => s.asama == Asama.tahsilat,
                bosEm: '💰',
                bosYazi: 'Tahsil edilecek alacak yok.',
                ozet: (l) =>
                    'Toplam alacak ${tl(l.fold(0.0, (a, s) => a + s.kalan))}');
          default:
            govde = _AnaSayfa(durum: d, git: _git, sekmeyeGit: sekmeyeGit);
        }
        return Scaffold(
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -1.25),
                radius: 1.1,
                colors: [Color(0xFF2A3A6E), Renk.zemin],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
                    child: Row(
                      children: [
                        _UstSimge(
                            em: '💼',
                            onTap: () => _git(AyarlarEkrani(durum: d))),
                        Expanded(
                            child: LogoBaslik(ad: f.ad, altyazi: f.altyazi)),
                        _UstSimge(
                          em: '📨',
                          rozet: nF + nT + nC,
                          onTap: () => sekmeyeGit(nF > 0
                              ? 1
                              : nT > 0
                                  ? 2
                                  : nC > 0
                                      ? 3
                                      : 0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Sayac(
                                em: '🪙',
                                deger: kisaTl(d.ciro),
                                etiket: 'Ciro',
                                cerceve: Renk.altin2,
                                simgeRenk: const [Color(0xFFFFE79A), Color(0xFFD39A1E)])),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Sayac(
                                em: '💎',
                                deger: sayi(d.siparisler.length),
                                etiket: 'Sipariş',
                                cerceve: const Color(0xFF7A5AE0),
                                simgeRenk: const [Color(0xFFD6B8FF), Color(0xFF7A42E0)])),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Sayac(
                                em: '⏳',
                                deger: kisaTl(d.alacak),
                                etiket: 'Alacak',
                                cerceve: const Color(0xFFE0A83A),
                                simgeRenk: const [Color(0xFFFFD98A), Color(0xFFE08A1A)])),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Sayac(
                                em: '💵',
                                deger: kisaTl(d.tahsil),
                                etiket: 'Tahsil',
                                cerceve: const Color(0xFF3FA34A),
                                simgeRenk: const [Color(0xFFA8F08A), Color(0xFF3F9A33)])),
                      ],
                    ),
                  ),
                  Expanded(child: govde),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _OrtaButon(onTap: () => yeniSiparis(context, d)),
          bottomNavigationBar: _AltMenu(
            secili: _sekme,
            rozetler: [0, nF, nT, nC],
            onTap: sekmeyeGit,
          ),
        );
      },
    );
  }
}

class _UstSimge extends StatelessWidget {
  const _UstSimge({required this.em, required this.onTap, this.rozet = 0});
  final String em;
  final VoidCallback onTap;
  final int rozet;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: InkResponse(
                onTap: onTap,
                radius: 28,
                child: Center(
                    child: Text(em,
                        style: const TextStyle(fontSize: 34, shadows: [
                          Shadow(color: Colors.black54, offset: Offset(0, 3), blurRadius: 3)
                        ]))),
              ),
            ),
            if (rozet > 0) Positioned(top: 2, right: 0, child: Rozet(sayi: rozet)),
          ],
        ),
      );
}

class _OrtaButon extends StatelessWidget {
  const _OrtaButon({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
                center: Alignment(0, -.3),
                colors: [Color(0xFF4F86F0), Color(0xFF1F45A8)]),
            border: Border.all(color: const Color(0xFF7AA6FF), width: 4),
            boxShadow: const [
              BoxShadow(color: Color(0xFF16203E), spreadRadius: 5),
              BoxShadow(color: Color(0x995080FF), blurRadius: 22, spreadRadius: 4),
            ],
          ),
          child: const Icon(Icons.add_rounded, size: 50, color: Colors.white),
        ),
      );
}

class _AltMenu extends StatelessWidget {
  const _AltMenu({required this.secili, required this.rozetler, required this.onTap});
  final int secili;
  final List<int> rozetler;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    Widget b(int i, String em, String ad) => Expanded(
          child: InkWell(
            onTap: () => onTap(i),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(em, style: const TextStyle(fontSize: 28)),
                    Text(ad,
                        style: TextStyle(
                            fontSize: 11,
                            color: secili == i ? Renk.altin : Renk.soluk)),
                  ],
                ),
                if (rozetler[i] > 0)
                  Positioned(top: 4, right: 14, child: Rozet(sayi: rozetler[i])),
                if (secili == i)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 46,
                      height: 4,
                      decoration: BoxDecoration(
                          color: const Color(0xFF4A8CFF),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
              ],
            ),
          ),
        );
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF22305A), Color(0xFF16203E)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: Color(0xFF2F3F6D), width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: [
              b(0, '🏠', 'Ana Sayfa'),
              b(1, '🏷️', 'Fiyat'),
              const SizedBox(width: 96),
              b(2, '🚚', 'Teslim'),
              b(3, '💰', 'Tahsilat'),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnaSayfa extends StatelessWidget {
  const _AnaSayfa(
      {required this.durum, required this.git, required this.sekmeyeGit});
  final Durum durum;
  final void Function(Widget) git;
  final ValueChanged<int> sekmeyeGit;

  @override
  Widget build(BuildContext context) {
    final d = durum;
    final ad = d.isim(d.uid);
    final bas = ad
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p.characters.first)
        .take(2)
        .join()
        .toUpperCase();
    final ciro = d.ciro, tah = d.tahsil;
    final oran = ciro > 0 ? (tah / ciro).clamp(0.0, 1.0) : 0.0;
    final bugun = DateTime.now();
    final gun = DateTime(bugun.year, bugun.month, bugun.day).millisecondsSinceEpoch;
    final bugunku = d.siparisler.where((s) => s.olusturma >= gun).length;
    final son = d.siparisler.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 120),
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                          center: Alignment(-.3, -.4),
                          colors: [Color(0xFF3A4F86), Color(0xFF1A2443)]),
                      border: Border.all(color: Renk.altin, width: 4),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF7A4A10), spreadRadius: 3),
                        BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Text(bas.isEmpty ? '👤' : bas,
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Renk.altin)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2443),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Renk.cizgi),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ad,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w700)),
                              Text('Bugün: $bugunku yeni sipariş',
                                  style: const TextStyle(color: Renk.soluk, fontSize: 13.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFFFE28A), Color(0xFFD79A1E)]),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFFF3C0)),
                              ),
                              child: Text(d.yonetici ? 'YÖNETİCİ' : 'EKİP',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF5A3200))),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text('Satış Paneli',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Renk.altin,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1630),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4B5F95), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: oran,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF86B4FF), Color(0xFF3F6FD6)]),
                          ),
                        ),
                      ),
                      Center(
                        child: Text('${sayi(tah.round())} / ${sayi(ciro.round())} ₺',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tahsilat oranı %${(oran * 100).round()} · Kalan alacak ${tl(d.alacak)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Renk.soluk, fontSize: 13.5),
              ),
            ],
          ),
        ),
        Panel(
          baslik: 'İş Akışı',
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .86,
            children: [
              Kutucuk(
                  adet: d.siparisler.length,
                  em: '🛒',
                  ad: 'Sipariş Gir',
                  alt: const Color(0xFF3A4F96),
                  kenar: const Color(0xFF6E8FE8),
                  onTap: () => yeniSiparis(context, d)),
              Kutucuk(
                  adet: d.sayi(Asama.fiyat),
                  em: '🏷️',
                  ad: 'Fiyat Bekleyen',
                  alt: const Color(0xFF4F7A3C),
                  kenar: const Color(0xFF6FAE4E),
                  nokta: true,
                  onTap: () => sekmeyeGit(1)),
              Kutucuk(
                  adet: d.sayi(Asama.teslim),
                  em: '📦',
                  ad: 'Teslim Bekleyen',
                  alt: const Color(0xFF7A6A48),
                  kenar: const Color(0xFFC9A86A),
                  nokta: true,
                  onTap: () => sekmeyeGit(2)),
              Kutucuk(
                  adet: d.sayi(Asama.tahsilat),
                  em: '💰',
                  ad: 'Tahsilat',
                  alt: const Color(0xFF47505E),
                  kenar: const Color(0xFF8A96AA),
                  nokta: true,
                  onTap: () => sekmeyeGit(3)),
              Kutucuk(
                  adet: d.sayi(Asama.tamam),
                  em: '✅',
                  ad: 'Tamamlanan',
                  alt: const Color(0xFF5B3AA8),
                  kenar: const Color(0xFF9B6CF0),
                  onTap: () => git(SiparisListesiEkrani(
                      durum: d,
                      baslik: 'Tamamlananlar',
                      filtre: (s) => s.asama == Asama.tamam,
                      bosEm: '✅',
                      bosYazi: 'Henüz tamamlanan sipariş yok.',
                      ozet: (l) =>
                          'Tahsil edilen ${tl(l.fold(0.0, (a, s) => a + s.odenen))}'))),
              Kutucuk(
                  adet: d.siparisler.length,
                  em: '📋',
                  ad: 'Tüm Siparişler',
                  alt: const Color(0xFF5A4636),
                  kenar: const Color(0xFFA5835F),
                  onTap: () => git(SiparisListesiEkrani(
                      durum: d,
                      baslik: 'Tüm Siparişler',
                      filtre: (_) => true,
                      asamaSecimi: true,
                      bosEm: '📋',
                      bosYazi: 'Kayıt bulunamadı.'))),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.85,
          children: [
            GenisButon(
                em: '👥',
                ad: 'Müşteriler',
                sol: '🔑',
                sag: '🎯',
                renkler: const [Color(0xFF3A2D7A), Color(0xFF7B3FE0)],
                kenar: const Color(0xFFA77CFF),
                onTap: () => git(OzetEkrani(durum: d, musteri: true))),
            GenisButon(
                em: '🌾',
                ad: 'Ürünler',
                sol: '🚀',
                sag: '🚜',
                renkler: const [Color(0xFF1F3A7A), Color(0xFF2F6BE0)],
                kenar: const Color(0xFF73A3FF),
                onTap: () => git(OzetEkrani(durum: d, musteri: false))),
            GenisButon(
                em: '🛒',
                ad: 'Sipariş Gir',
                sol: '📝',
                sag: '🚛',
                serit: 'Yeni',
                renkler: const [Color(0xFF25463A), Color(0xFF3F8F33)],
                kenar: const Color(0xFF7AD06A),
                onTap: () => yeniSiparis(context, d)),
            GenisButon(
                em: '🏢',
                ad: 'Ayarlar',
                sol: '⚙️',
                sag: '🧺',
                renkler: const [Color(0xFF4A2240), Color(0xFFC03A4A)],
                kenar: const Color(0xFFFF8A8A),
                onTap: () => git(AyarlarEkrani(durum: d))),
          ],
        ),
        const SizedBox(height: 14),
        Panel(
          baslik: 'Son Hareketler',
          child: !d.yuklendi
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: Renk.altin)))
              : son.isEmpty
                  ? const BosDurum(
                      em: '🛒',
                      yazi: 'Henüz sipariş yok.\nOrtadaki ＋ ile ilk siparişi girin.')
                  : Column(
                      children: [for (final s in son) SiparisKarti(durum: d, s: s)]),
        ),
      ],
    );
  }
}
