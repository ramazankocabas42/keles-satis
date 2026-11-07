import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../servis/veri.dart';
import '../tema.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _form = GlobalKey<FormState>();
  final _eposta = TextEditingController();
  final _sifre = TextEditingController();
  bool _kayit = false;
  bool _mesgul = false;
  bool _gizli = true;

  @override
  void dispose() {
    _eposta.dispose();
    _sifre.dispose();
    super.dispose();
  }

  Future<void> _gonder() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _mesgul = true);
    try {
      final a = FirebaseAuth.instance;
      if (_kayit) {
        await a.createUserWithEmailAndPassword(
            email: _eposta.text.trim(), password: _sifre.text);
      } else {
        await a.signInWithEmailAndPassword(
            email: _eposta.text.trim(), password: _sifre.text);
      }
    } catch (e) {
      if (mounted) bildir(context, hataYazisi(e));
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  Future<void> _sifreSifirla() async {
    final e = _eposta.text.trim();
    if (!e.contains('@')) {
      bildir(context, 'Önce e-posta adresinizi yazın.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: e);
      if (mounted) bildir(context, 'Şifre sıfırlama bağlantısı e-postanıza gönderildi.');
    } catch (err) {
      if (mounted) bildir(context, hataYazisi(err));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('🌾', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 8),
                    const LogoBaslik(ad: 'KELEŞ TARIM', altyazi: 'SATIŞ & TİCARET'),
                    const SizedBox(height: 28),
                    Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_kayit ? 'Yeni hesap' : 'Giriş yap',
                              style: const TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _eposta,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                                labelText: 'E-posta',
                                prefixIcon: Icon(Icons.mail_outline)),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Geçerli bir e-posta yazın'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _sifre,
                            obscureText: _gizli,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_gizli
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _gizli = !_gizli),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Şifre en az 6 karakter olmalı'
                                : null,
                            onFieldSubmitted: (_) => _gonder(),
                          ),
                          const SizedBox(height: 18),
                          OyunButonu(
                            yazi: _kayit ? 'Hesap Oluştur' : 'Giriş Yap',
                            renk: ButonRenk.yesil,
                            mesgul: _mesgul,
                            yukseklik: 52,
                            onTap: _gonder,
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: _mesgul
                                ? null
                                : () => setState(() => _kayit = !_kayit),
                            child: Text(_kayit
                                ? 'Zaten hesabım var, giriş yap'
                                : 'Hesabım yok, yeni hesap oluştur'),
                          ),
                          if (!_kayit)
                            TextButton(
                                onPressed: _mesgul ? null : _sifreSifirla,
                                child: const Text('Şifremi unuttum')),
                        ],
                      ),
                    ),
                    const Text(
                      'Eğitim Takip hesabınız varsa aynı e-posta ve şifreyle girebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Renk.soluk, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
