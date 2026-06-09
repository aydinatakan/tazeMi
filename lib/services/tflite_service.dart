import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  // Sınıf isimleri (Python tarafındaki eğitim sırasıyla aynı olmalı)
  final List<String> _labels = ['Fresh', 'Rotten', 'Semi-Rotten'];

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      // Android'de GPU delegasyonu bazen emülatörde hata verebilir, 
      // bu yüzden varsayılan seçeneklerle başlıyoruz.
      _interpreter = await Interpreter.fromAsset('assets/model.tflite', options: options);
      print('✅ TFLite: Model yüklendi.');
    } catch (e) {
      print('❌ TFLite Yükleme Hatası: $e');
    }
  }

  Future<Map<String, dynamic>?> predictImage(File imageFile) async {
    if (_interpreter == null) await loadModel();
    if (_interpreter == null) return null;

    try {
      // 1. Görüntü işleme
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // 224x224 boyutuna getir
      final resized = img.copyResize(image, width: 224, height: 224);

      // 2. Giriş (Input) Tensorunu oluştur [1, 224, 224, 3]
      // Dart'ta çok boyutlu listeyi en güvenli şekilde oluşturuyoruz
      var input = List.generate(1, (_) => 
        List.generate(224, (_) => 
          List.generate(224, (_) => 
            List.filled(3, 0.0)
          )
        )
      );

      // Pikselleri yerleştir (Normalizasyon model içindeki Lambda katmanında yapılıyor)
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          input[0][y][x][0] = pixel.r.toDouble();
          input[0][y][x][1] = pixel.g.toDouble();
          input[0][y][x][2] = pixel.b.toDouble();
        }
      }

      // 3. Çıkış (Output) Tensorunu oluştur [1, 3]
      // Reshape hatasını önlemek için List<dynamic> olarak cast ediyoruz
      var output = List<double>.filled(3, 0).reshape([1, 3]);

      // 4. Modeli çalıştır
      _interpreter!.run(input, output);

      // 5. Sonuçları işle
      final probabilities = output[0] as List<double>;
      double maxProb = -1.0;
      int maxIndex = 0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      return {
        'label': _labels[maxIndex],
        'confidence': maxProb * 100,
      };
    } catch (e) {
      print('❌ TFLite Tahmin Hatası: $e');
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
