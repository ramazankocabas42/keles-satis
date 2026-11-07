import 'package:flutter_test/flutter_test.dart';
import 'package:keles_satis/modeller.dart';

Siparis _s({double? fiyat, bool teslim = false, List<double> odemeler = const []}) =>
    Siparis(
      id: '1',
      no: 1,
      musteri: 'Ahmet',
      urun: 'Domates',
      miktar: 100,
      birim: 'kg',
      olusturan: 'u',
      olusturma: 1,
      fiyat: fiyat,
      teslim: teslim,
      tahsilatlar: [
        for (final o in odemeler) Tahsilat(tutar: o, yontem: 'Nakit', tarih: 1, by: 'u')
      ],
    );

void main() {
  test('Aşamalar sırayla ilerler', () {
    expect(_s().asama, Asama.fiyat);
    expect(_s(fiyat: 12.5).asama, Asama.teslim);
    expect(_s(fiyat: 12.5, teslim: true).asama, Asama.tahsilat);
    expect(_s(fiyat: 12.5, teslim: true, odemeler: [1250]).asama, Asama.tamam);
  });

  test('Kısmi tahsilat ve kalan', () {
    final s = _s(fiyat: 12.5, teslim: true, odemeler: [500, 250.25]);
    expect(s.toplam, 1250);
    expect(s.odenen, 750.25);
    expect(s.kalan, 499.75);
    expect(s.asama, Asama.tahsilat);
  });

  test('Fazla ödeme kalanı eksiye düşürmez', () {
    final s = _s(fiyat: 10, teslim: true, odemeler: [1500]);
    expect(s.kalan, 0);
    expect(s.asama, Asama.tamam);
  });

  test('Sayı okuma (Türkçe yazım)', () {
    expect(sayiOku('1.234,5'), 1234.5);
    expect(sayiOku('12,75'), 12.75);
    expect(sayiOku('15.5'), 15.5);
    expect(sayiOku(' 2 500 '), 2500);
    expect(sayiOku(''), isNull);
    expect(sayiOku('abc'), isNull);
  });

  test('Firma ürün bulma büyük/küçük harf duyarsız', () {
    const f = Firma(
      id: 'f',
      ad: 'KELEŞ TARIM',
      altyazi: '',
      sahip: 'u',
      uyeler: ['u'],
      yoneticiler: ['u'],
      birimler: [],
      urunler: [Urun(ad: 'Domates', birim: 'kasa', fiyat: 150, em: '🍅')],
      kod: 'X',
      sayac: 0,
    );
    expect(f.urunBul(' domates ')?.birim, 'kasa');
    expect(f.birimListesi, varsayilanBirimler);
    expect(f.yonetici('u'), isTrue);
  });
}
