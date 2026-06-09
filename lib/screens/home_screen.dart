import 'package:flutter/material.dart';
import 'detect_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The visual design from image_0.png is very clean and bright.
    // It uses standard Flutter elements for text, icons, and a card-like list.
    // The background is a simple, clean, slightly off-white, and
    // the content is arranged vertically.

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Clean, off-white background
      body: SingleChildScrollView(
        // Allow scrolling on smaller screens
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Hoş Geldiniz Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Hoş Geldiniz',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(text: ' '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: const Text('👋',
                                style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // For small screen spacing
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Elma tazelik kontrolüne hazır mısınız?',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),

              // --- Central Apple Icon Container ---
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853), // Prominent vibrant green
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFC8E6C9), // Light green shadow
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.apple, // Outline style standard Flutter icon
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // --- Stylized Description Text ---
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text:
                      'Elmanızın ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'taze mi',
                          style: TextStyle(
                            color: Color(0xFF00C853), // Matching green
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' yoksa '),
                        TextSpan(
                          text: 'çürük mü',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' olduğunu saniyeler içinde öğrenin.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- Fotoğraf Analiz Et Button (Restyled) ---
              ElevatedButton(
                // Kept original function
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DetectScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853), // Solid vibrant green
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Less round, more clean
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Fotoğraf Analiz Et', // Correct case
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- Feature Cards Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureCard(
                    icon: Icons.bolt,
                    iconColor: const Color(0xFF00C853),
                    title: 'Hızlı Analiz',
                    subtitle: 'Saniyeler içinde sonuç',
                  ),
                  const SizedBox(width: 10),
                  _buildFeatureCard(
                    icon: Icons.wifi_off,
                    iconColor: const Color(0xFF00C853),
                    title: 'Offline Çalışma',
                    subtitle: 'İnternet gerektirmez',
                  ),
                  const SizedBox(width: 10),
                  _buildFeatureCard(
                    icon: Icons.psychology_outlined,
                    iconColor: const Color(0xFF00C853),
                    title: 'Yapay Zeka',
                    subtitle: 'Gelişmiş AI teknolojisi',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}