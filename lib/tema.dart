import 'package:flutter/material.dart';

/// Oyun tarzı koyu lacivert tema ve ortak parçalar.
class Renk {
  static const zemin = Color(0xFF141C33);
  static const zemin2 = Color(0xFF1B2542);
  static const kart = Color(0xFF202C4D);
  static const kart2 = Color(0xFF26345A);
  static const cizgi = Color(0xFF34446F);
  static const yazi = Color(0xFFEEF2FF);
  static const soluk = Color(0xFF9AA6C8);
  static const altin = Color(0xFFF5C542);
  static const altin2 = Color(0xFFD9922B);
  static const yesil = Color(0xFF5FBF4A);
  static const mavi = Color(0xFF4A7FE0);
  static const mor = Color(0xFF8B4FE6);
  static const kirmizi = Color(0xFFEC4949);
  static const girdi = Color(0xFF121A31);
}

ThemeData temaOlustur() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Renk.altin,
      brightness: Brightness.dark,
      surface: Renk.zemin2,
      primary: Renk.altin,
    ),
    scaffoldBackgroundColor: Renk.zemin,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFF3A4A78), width: 2),
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Renk.zemin,
      foregroundColor: Renk.yazi,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: Renk.yazi),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Renk.girdi,
      labelStyle: const TextStyle(color: Renk.soluk),
      hintStyle: const TextStyle(color: Color(0xFF6F7BA0)),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Renk.altin, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF0E1428),
      contentTextStyle: TextStyle(color: Renk.yazi, fontSize: 15),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Renk.altin, width: 2)),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Renk.kart2),
    textTheme: base.textTheme.apply(bodyColor: Renk.yazi, displayColor: Renk.yazi),
  );
}

void bildir(BuildContext context, String mesaj) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mesaj, textAlign: TextAlign.center)));
}

/// Altın renkli, kenarlıklı logo yazısı ve altındaki kırmızı şerit.
class LogoBaslik extends StatelessWidget {
  const LogoBaslik({super.key, required this.ad, required this.altyazi});

  final String ad;
  final String altyazi;

  @override
  Widget build(BuildContext context) {
    const stil = TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: .5,
        height: 1.05);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            children: [
              Text(ad,
                  style: stil.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = const Color(0xFF4A1D02),
                    shadows: const [
                      Shadow(offset: Offset(0, 3), color: Color(0xFF2A1003))
                    ],
                  )),
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF6C9), Color(0xFFF9D34A), Color(0xFFE38A12)],
                  stops: [0, .45, 1],
                ).createShader(r),
                child: Text(ad, style: stil.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
        if (altyazi.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFC82A2A), Color(0xFF8F1515)]),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Renk.altin, width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0xFF4A0B0B), offset: Offset(0, 3))
              ],
            ),
            child: Text(altyazi,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: Colors.white)),
          ),
      ],
    );
  }
}

class Rozet extends StatelessWidget {
  const Rozet({super.key, required this.sayi});
  final int sayi;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Renk.kirmizi,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Renk.zemin, width: 2),
        ),
        child: Text('$sayi',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      );
}

class KirmiziNokta extends StatelessWidget {
  const KirmiziNokta({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Renk.kirmizi,
          shape: BoxShape.circle,
          border: Border.all(color: Renk.zemin2, width: 2),
        ),
      );
}

/// Üstteki sayaç hapları (simge yuvarlak, sola taşan).
class Sayac extends StatelessWidget {
  const Sayac({
    super.key,
    required this.em,
    required this.deger,
    required this.etiket,
    required this.cerceve,
    required this.simgeRenk,
  });

  final String em;
  final String deger;
  final String etiket;
  final Color cerceve;
  final List<Color> simgeRenk;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 46,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0B1124), Color(0xFF18213F)]),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cerceve, width: 3),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(left: 30, right: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(deger,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 1,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                        center: const Alignment(-.3, -.4), colors: simgeRenk),
                    boxShadow: [
                      BoxShadow(
                          color: simgeRenk.last.withValues(alpha: .6),
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(em, style: const TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(etiket, style: const TextStyle(fontSize: 11, color: Renk.soluk)),
      ],
    );
  }
}

/// Yuvarlak köşeli koyu panel ve başlığı.
class Panel extends StatelessWidget {
  const Panel({super.key, this.baslik, required this.child, this.margin});

  final String? baslik;
  final Widget child;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Renk.kart2, Renk.kart]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2F3F6A)),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (baslik != null) ...[
            Text(baslik!,
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: .6,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF6C7BA8), Colors.transparent])),
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

/// "21 Adet" yazılı büyük kare kutucuk.
class Kutucuk extends StatelessWidget {
  const Kutucuk({
    super.key,
    required this.adet,
    required this.em,
    required this.ad,
    required this.alt,
    required this.kenar,
    this.nokta = false,
    required this.onTap,
  });

  final int adet;
  final String em;
  final String ad;
  final Color alt;
  final Color kenar;
  final bool nokta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF26345E), alt]),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: .08), width: 2),
                  left: BorderSide(color: Colors.white.withValues(alpha: .08), width: 2),
                  right: BorderSide(color: Colors.white.withValues(alpha: .08), width: 2),
                  bottom: BorderSide(color: kenar, width: 4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$adet Adet', style: const TextStyle(fontSize: 14)),
                    Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white24),
                    Expanded(
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(em,
                              style: const TextStyle(fontSize: 48, shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                    offset: Offset(0, 4))
                              ])),
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(ad,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(color: Colors.black45, offset: Offset(0, 2))
                              ])),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (nokta && adet > 0)
          const Positioned(top: -6, right: -6, child: KirmiziNokta()),
      ],
    );
  }
}

/// Ana sayfadaki büyük renkli geniş butonlar.
class GenisButon extends StatelessWidget {
  const GenisButon({
    super.key,
    required this.em,
    required this.ad,
    required this.renkler,
    required this.kenar,
    required this.onTap,
    this.sol,
    this.sag,
    this.serit,
  });

  final String em;
  final String ad;
  final List<Color> renkler;
  final Color kenar;
  final VoidCallback onTap;
  final String? sol;
  final String? sag;
  final String? serit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: renkler),
            borderRadius: BorderRadius.circular(18),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: .12), width: 2),
              left: BorderSide(color: Colors.white.withValues(alpha: .12), width: 2),
              right: BorderSide(color: Colors.white.withValues(alpha: .12), width: 2),
              bottom: BorderSide(color: kenar, width: 4),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (sol != null)
                  Positioned(
                      left: 10,
                      top: 8,
                      child: Text(sol!, style: const TextStyle(fontSize: 22))),
                if (sag != null)
                  Positioned(
                      right: 10,
                      bottom: 8,
                      child: Text(sag!, style: const TextStyle(fontSize: 22))),
                if (serit != null)
                  Positioned(
                    top: 10,
                    right: -28,
                    child: Transform.rotate(
                      angle: .7,
                      child: Container(
                        color: Renk.kirmizi,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 2),
                        child: Text(serit!,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(em, style: const TextStyle(fontSize: 32)),
                      Text(ad,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(color: Colors.black38, offset: Offset(0, 2))
                              ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ButonRenk { yesil, mavi, sari, mor, gri, kirmizi }

/// Alt kenarı kalın, üç boyutlu görünen buton.
class OyunButonu extends StatelessWidget {
  const OyunButonu({
    super.key,
    required this.yazi,
    required this.renk,
    required this.onTap,
    this.mesgul = false,
    this.yukseklik = 46,
  });

  final String yazi;
  final ButonRenk renk;
  final VoidCallback? onTap;
  final bool mesgul;
  final double yukseklik;

  @override
  Widget build(BuildContext context) {
    final (List<Color> r, Color y) = switch (renk) {
      ButonRenk.yesil => (const [Color(0xFF76D05E), Color(0xFF46A136)], Colors.white),
      ButonRenk.mavi => (const [Color(0xFF5D8FEE), Color(0xFF2F5BC0)], Colors.white),
      ButonRenk.sari => (const [Color(0xFFFFD46A), Color(0xFFE09A1F)], const Color(0xFF4A2A00)),
      ButonRenk.mor => (const [Color(0xFF9B6CF0), Color(0xFF6A37C9)], Colors.white),
      ButonRenk.gri => (const [Color(0xFF3A4872), Color(0xFF2C3860)], Colors.white),
      ButonRenk.kirmizi => (const [Color(0xFFF06A6A), Color(0xFFC23030)], Colors.white),
    };
    final pasif = onTap == null || mesgul;
    return Opacity(
      opacity: pasif && !mesgul ? .45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: pasif ? null : onTap,
          child: Ink(
            height: yukseklik,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: r),
              borderRadius: BorderRadius.circular(13),
              border: const Border(
                  bottom: BorderSide(color: Color(0x55000000), width: 3)),
            ),
            child: Center(
              child: mesgul
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: y))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(yazi,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: y)),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sipariş kartındaki küçük kare bilgi kutusu.
class Cip extends StatelessWidget {
  const Cip({super.key, required this.ust, required this.deger, this.durum});

  final String ust;
  final String deger;

  /// null: normal, true: iyi (yeşil), false: uyarı (kırmızı)
  final bool? durum;

  @override
  Widget build(BuildContext context) {
    final kenar = durum == null
        ? const Color(0xFF56688F)
        : durum!
            ? const Color(0xFF3F8F33)
            : const Color(0xFFAA3333);
    final zemin = durum == null
        ? const Color(0xFF2C3A62)
        : durum!
            ? const Color(0xFF213A2C)
            : const Color(0xFF3A2236);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      decoration: BoxDecoration(
        color: zemin,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kenar, width: 2),
      ),
      child: Column(
        children: [
          Text(ust,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: Renk.soluk)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(deger,
                maxLines: 1,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Yuvarlak simgeli küçük etiket ("12sa", "Tanıtım yok" benzeri).
class Etiket extends StatelessWidget {
  const Etiket(
      {super.key,
      required this.isaret,
      required this.yazi,
      this.renk = Colors.white,
      this.isaretRenk = const Color(0xFFCC3333)});

  final String isaret;
  final String yazi;
  final Color renk;
  final Color isaretRenk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 10, 3),
      decoration: BoxDecoration(
          color: const Color(0xFF2A3557),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
            child: Text(isaret,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, color: isaretRenk)),
          ),
          const SizedBox(width: 5),
          Text(yazi, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class BosDurum extends StatelessWidget {
  const BosDurum({super.key, required this.em, required this.yazi});
  final String em;
  final String yazi;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
        child: Column(
          children: [
            Text(em, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text(yazi,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Renk.soluk, fontSize: 16)),
          ],
        ),
      );
}

/// Alttan açılan, altın çizgili form sayfası.
Future<T?> altSayfa<T>(BuildContext context,
    {required String baslik,
    String? aciklama,
    required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF26345E), Color(0xFF1B2545)]),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Renk.altin, width: 3)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(baslik,
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Renk.altin)),
              if (aciklama != null) ...[
                const SizedBox(height: 4),
                Text(aciklama,
                    style: const TextStyle(color: Renk.soluk, fontSize: 14)),
              ],
              const SizedBox(height: 14),
              _BirKez(builder: builder),
            ],
          ),
        ),
      ),
    ),
  );
}

/// İçeriği yalnızca bir kez kurar; klavye açılıp kapanınca formdaki
/// denetleyiciler (yazılan metin) kaybolmaz.
class _BirKez extends StatefulWidget {
  const _BirKez({required this.builder});
  final WidgetBuilder builder;

  @override
  State<_BirKez> createState() => _BirKezState();
}

class _BirKezState extends State<_BirKez> {
  Widget? _icerik;

  @override
  Widget build(BuildContext context) => _icerik ??= widget.builder(context);
}

/// Yazarken öneri gösteren metin kutusu.
class OneriliAlan extends StatelessWidget {
  const OneriliAlan({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.secenekler,
    required this.etiket,
    this.ipucu,
    this.onSecildi,
    this.onDegisti,
    this.buyukHarf = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Iterable<String> secenekler;
  final String etiket;
  final String? ipucu;
  final ValueChanged<String>? onSecildi;
  final ValueChanged<String>? onDegisti;
  final TextCapitalization buyukHarf;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (v) {
        final q = v.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return secenekler
            .where((m) => m.toLowerCase().contains(q) && m.toLowerCase() != q)
            .take(8);
      },
      onSelected: (v) => onSecildi?.call(v),
      fieldViewBuilder: (c, ctrl, fn, gonder) => TextField(
        controller: ctrl,
        focusNode: fn,
        textCapitalization: buyukHarf,
        onChanged: onDegisti,
        decoration: InputDecoration(labelText: etiket, hintText: ipucu),
      ),
      optionsViewBuilder: (c, sec, liste) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: Renk.kart2,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220, maxWidth: 360),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final o in liste)
                  ListTile(dense: true, title: Text(o), onTap: () => sec(o)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToplamKutusu extends StatelessWidget {
  const ToplamKutusu({super.key, required this.etiket, required this.deger});
  final String etiket;
  final String deger;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Renk.girdi,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Renk.altin2, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Text(etiket)),
            Text(deger,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Renk.altin)),
          ],
        ),
      );
}
