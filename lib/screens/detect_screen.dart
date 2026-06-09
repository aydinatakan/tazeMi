import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/tflite_service.dart';

class DetectScreen extends StatefulWidget {
  const DetectScreen({super.key});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tfLiteService = TFLiteService();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Ses çalar nesnesi

  String _label = '';
  double _confidence = 0.0;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _tfLiteService.loadModel();
  }

  @override
  void dispose() {
    _tfLiteService.dispose();
    _audioPlayer.dispose(); // Ses çaları bellekten temizle
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _label = ''; // Yeni resim seçildiğinde eski sonucu temizle
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    final result = await _tfLiteService.predictImage(_image!);

    if (result != null) {
      setState(() {
        _label = result['label'];
        _confidence = result['confidence'];
        _isAnalyzing = false;
      });

      // --- SES ÇALMA MANTIĞI ---
      _playResultSound(result['label']);
    } else {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  // Sonuca göre ses dosyasını çal
  Future<void> _playResultSound(String label) async {
    String soundPath = '';
    
    if (label == 'Fresh') {
      soundPath = 'sounds/fresh.mp3';
    } else if (label == 'Rotten') {
      soundPath = 'sounds/rotten.mp3';
    } else if (label == 'Semi-Rotten') {
      soundPath = 'sounds/semi_rotten.mp3';
    }

    if (soundPath.isNotEmpty) {
      try {
        await _audioPlayer.play(AssetSource(soundPath));
      } catch (e) {
        print('Ses çalma hatası: $e');
      }
    }
  }

  String _translate(String label) {
    if (label == 'Fresh') return 'Taze Elma';
    if (label == 'Rotten') return 'Çürük Elma';
    if (label == 'Semi-Rotten') return 'Çürümekte Olan Elma'; // Tasarıma uyum için ' Elma' eklendi
    return label;
  }

  // --- UI YARDIMCI DEĞİŞKENLERİ (Tasarıma göre renk ve ikon belirlemek için) ---
  Map<String, dynamic> _getResultUIConfig(String label) {
    if (label == 'Fresh') {
      return {
        'color': const Color(0xFF00C853), // Yeşil
        'icon': Icons.check,
        'bg': const Color(0xFFE8F5E9),
        'desc': 'Elmanız tamamen taze ve tüketime uygun.',
      };
    } else if (label == 'Rotten') {
      return {
        'color': const Color(0xFFD32F2F), // Kırmızı
        'icon': Icons.close,
        'bg': const Color(0xFFFFEBEE),
        'desc': 'Elmanız çürümüş, lütfen tüketmeyin.',
      };
    } else {
      // Semi-Rotten veya varsayılan
      return {
        'color': const Color(0xFFFF6D00), // Turuncu (Görseldeki gibi)
        'icon': Icons.priority_high,
        'bg': const Color(0xFFFFF6ED),
        'desc': 'Elmanızda çürüme belirtileri var, yakında tüketin.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eğer analiz yapıldıysa sonuç ekranını, yapılmadıysa seçim ekranını gösteriyoruz.
    bool isResultScreen = _label.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- ÜST BAR (AppBar Yerine) ---
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 20),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isResultScreen ? 'Analiz Sonucu' : 'Fotoğraf Analizi',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Başlığı ortalamak için boşluk
                  ],
                ),
                const SizedBox(height: 100),

                // ----------------------------------------------------
                // 1. DURUM: FOTOĞRAF SEÇİM VE ANALİZ EKRANI
                // ----------------------------------------------------
                if (!isResultScreen) ...[
                  // Görüntü / Placeholder Alanı
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      image: _image != null
                          ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _image == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.image_outlined, size: 40, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Henüz fotoğraf seçilmedi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kamera veya galeriden bir fotoğraf seçin',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    )
                        : null,
                  ),
                  const SizedBox(height: 75),

                  // Butonlar (Kamera ve Galeri)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2970FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Kamera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA838FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galeri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Analiz Et Butonu
                  ElevatedButton.icon(
                    onPressed: (_image == null || _isAnalyzing) ? null : _analyzeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7EE2A8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF7EE2A8).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: _isAnalyzing
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isAnalyzing ? 'Analiz Ediliyor...' : 'Analiz Et',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Analiz etmek için bir fotoğraf seçin',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],

                // ----------------------------------------------------
                // 2. DURUM: ANALİZ SONUCU EKRANI
                // ----------------------------------------------------
                if (isResultScreen) ...[
                  // Analiz Edilen Fotoğraf
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(_image!, height: 320, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),

                  // Sonuç Kartı
                  Builder(
                      builder: (context) {
                        final config = _getResultUIConfig(_label);
                        final Color themeColor = config['color'];
                        final Color bgColor = config['bg'];

                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              // İkon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(config['icon'], color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 16),

                              // Başlık
                              Text(
                                _translate(_label),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Açıklama
                              Text(
                                config['desc'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF334155),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Doğruluk Oranı Çubuğu
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Doğruluk Oranı',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                        Text(
                                          '%${_confidence.toStringAsFixed(2)}', // 2 haneli hassasiyet: %99.99
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: themeColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Özel İlerleme Çubuğu
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2E8F0),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: (_confidence / 100).clamp(0.0, 1.0), // Değer 0-100 olduğu için 100'e bölüyoruz
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: themeColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),

                  const SizedBox(height: 24),

                  // Analiz Sayfasına Dön Butonu (Yeni İstek)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _image = null;
                        _label = '';
                        _confidence = 0.0;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Yeni Analiz Yap',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}