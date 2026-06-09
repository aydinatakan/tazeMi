import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Logo animasyonu için controller (DOKUNULMADI)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // 3 saniye sonra Ana Sayfa'ya geçiş yap (DOKUNULMADI)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tasarımdaki çok açık renkli / beyaz arka plan
      backgroundColor: const Color(0xFFFBFBFB),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasyonlu Logo
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853), // Tasarımdaki canlı yeşil
                  borderRadius: BorderRadius.circular(30), // Kare ama köşeleri yuvarlatılmış (Squircle)
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C853).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.apple,
                    size: 70,
                    color: Colors.white, // Beyaz elma ikonu
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Uygulama Adı (Tasarıma göre güncellendi)
            const Text(
              'TazeMi',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900, // Kalın font
                color: Color(0xFF0F172A), // Koyu lacivert/siyah renk
              ),
            ),
            const SizedBox(height: 8),
            // Alt Başlık
            const Text(
              'Yapay Zeka ile Elma Tazelik Analizi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF475569), // Gri renk
              ),
            ),

            const SizedBox(height: 60),

            // Alt kısımdaki 3'lü nokta (LinearProgressIndicator yerine tasarımdaki noktalar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.4), // Soluk yeşil
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853), // Canlı yeşil
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853), // Canlı yeşil
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}