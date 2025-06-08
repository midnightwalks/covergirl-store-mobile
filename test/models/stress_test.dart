import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

// Dummy ColorOption class
class ColorOption {
  final String hexValue;
  final String colorName;

  ColorOption({required this.hexValue, required this.colorName});

  Map<String, dynamic> toJson() => {
        'hex_value': hexValue,
        'colour_name': colorName,
      };
}

// Dummy ContentModel class (disesuaikan dengan struktur aslimu)
class ContentModel {
  final String id;
  final String brand;
  final String name;
  final String price;
  final String priceSign;
  final String currency;
  final String imageUrl;
  final String productLink;
  final String websiteLink;
  final String description;
  final String category;
  final String productType;
  final List<String> tagList;
  final String createdAt;
  final String updatedAt;
  final String productApiUrl;
  final String apiFeaturedImage;
  final List<ColorOption> productColors;
  final double? rating;

  ContentModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.priceSign,
    required this.currency,
    required this.imageUrl,
    required this.productLink,
    required this.websiteLink,
    required this.description,
    required this.category,
    required this.productType,
    required this.tagList,
    required this.createdAt,
    required this.updatedAt,
    required this.productApiUrl,
    required this.apiFeaturedImage,
    required this.productColors,
    this.rating,
  });
}

void main() {
  const int stressCreateCount = 10000;
  const int stressAsyncOpCount = 5000;
  const int stressBulkAddCount = 15000;
  final Random random = Random();

  ContentModel generateDummyContentModel(int id) {
    return ContentModel(
      id: '$id',
      brand: 'Brand $id',
      name: 'Product $id',
      price: (random.nextDouble() * 100).toStringAsFixed(2),
      priceSign: '\$',
      currency: 'USD',
      imageUrl: 'https://example.com/img$id.png',
      productLink: 'https://example.com/product/$id',
      websiteLink: 'https://example.com',
      description: 'Description for product $id',
      category: 'Category ${id % 5}',
      productType: 'Type ${id % 3}',
      tagList: ['tag${id % 2}', 'tag${(id + 1) % 2}'],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      productApiUrl: 'https://api.example.com/product/$id',
      apiFeaturedImage: 'https://example.com/featured/$id.png',
      productColors: List.generate(3, (i) => ColorOption(
        hexValue: '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        colorName: 'Color $i')),
      rating: (random.nextDouble() * 5),
    );
  }

  group('ContentModel Stress Testing', () {
    test('Create $stressCreateCount ContentModel objects', () {
      final stopwatch = Stopwatch()..start();
      final models = List.generate(stressCreateCount, (i) => generateDummyContentModel(i));
      stopwatch.stop();
      print('[Stress Test 1] Time to create $stressCreateCount ContentModel objects: ${stopwatch.elapsedMilliseconds}ms');
      expect(models.length, stressCreateCount);
    });

    test('Perform $stressAsyncOpCount async operations on ContentModel', () async {
      final models = List.generate(1000, (i) => generateDummyContentModel(i));
      final stopwatch = Stopwatch()..start();

      final ops = List.generate(stressAsyncOpCount, (i) async {
        final action = i % 3;
        if (action == 0) {
          final model = models[random.nextInt(models.length)];
          return model.name;
        } else if (action == 1) {
          final model = generateDummyContentModel(i);
          return double.parse(model.price) * 1.1;
        } else {
          return models.where((m) => double.parse(m.price) > 50).length;
        }
      });

      await Future.wait(ops);
      stopwatch.stop();
      print('[Stress Test 2] $stressAsyncOpCount async operations completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Bulk add $stressBulkAddCount ContentModel objects to list', () {
      final stopwatch = Stopwatch()..start();
      final List<ContentModel> bulkList = [];
      for (int i = 0; i < stressBulkAddCount; i++) {
        bulkList.add(generateDummyContentModel(i));
      }
      stopwatch.stop();
      print('[Stress Test 3] Time to bulk add $stressBulkAddCount ContentModel objects: ${stopwatch.elapsedMilliseconds}ms');
      expect(bulkList.length, stressBulkAddCount);
    });
  });
}