import 'package:flutter_test/flutter_test.dart';
import 'package:covergirlstore/api/apiService.dart';
import 'package:covergirlstore/models/contentModel.dart';

void main() {
  group('Integration Test - ApiService', () {
    
    test('GET semua produk - fetchData returns list of ContentModel', () async {
      final data = await ApiService.fetchData('covergirl');
      expect(data, isA<List<ContentModel>>());
      expect(data.isNotEmpty, true);
    });

    test('Validasi parsing JSON ke ContentModel', () async {
      final data = await ApiService.fetchData('covergirl');
      final first = data.first;

      expect(first.id, isNotEmpty);
      expect(first.brand, isNotEmpty);
      expect(first.name, isNotEmpty);
      expect(first.productColors, isA<List<ColorOption>>());
    });

    test('Respons error saat brand kosong', () async {
      try {
        await ApiService.fetchData('');
        fail('Expected exception not thrown');
      } catch (e) {
        expect(e.toString(), contains('Brand tidak boleh kosong'));
      }
    });

    test('Respons waktu cepat di bawah 1000ms', () async {
      final stopwatch = Stopwatch()..start();
      await ApiService.fetchData('covergirl');
      stopwatch.stop();

      print('Response time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds < 1000, true);
    });

  });
}