import 'package:flutter_test/flutter_test.dart';
import 'package:covergirlstore/models/contentModel.dart'; // Sesuaikan dengan path kamu

void main() {
  group('ContentModel', () {
    test('fromJson and toJson should work correctly', () {
      final json = {
        'id': '101',
        'brand': 'Brand X',
        'name': 'Lipstick Matte',
        'price': '12.99',
        'price_sign': '\$',
        'currency': 'USD',
        'image_link': 'https://example.com/image.jpg',
        'product_link': 'https://example.com/product',
        'website_link': 'https://example.com',
        'description': 'High quality lipstick.',
        'category': 'makeup',
        'product_type': 'lipstick',
        'tag_list': ['vegan', 'cruelty-free'],
        'created_at': '2023-01-01T00:00:00',
        'updated_at': '2023-06-01T00:00:00',
        'product_api_url': 'https://api.example.com/product/101',
        'api_featured_image': 'https://example.com/featured.jpg',
        'product_colors': [
          {
            'hex_value': '#FF5733',
            'colour_name': 'Sunset Red',
          },
          {
            'hex_value': '#C70039',
            'colour_name': 'Berry Red',
          }
        ],
        'rating': 4.5,
      };

      final model = ContentModel.fromJson(json);

      // Test proper decoding
      expect(model.id, '101');
      expect(model.brand, 'Brand X');
      expect(model.name, 'Lipstick Matte');
      expect(model.price, '12.99');
      expect(model.priceSign, '\$');
      expect(model.currency, 'USD');
      expect(model.imageUrl, 'https://example.com/image.jpg');
      expect(model.productLink, 'https://example.com/product');
      expect(model.websiteLink, 'https://example.com');
      expect(model.description, 'High quality lipstick.');
      expect(model.category, 'makeup');
      expect(model.productType, 'lipstick');
      expect(model.tagList.length, 2);
      expect(model.tagList.first, 'vegan');
      expect(model.createdAt, '2023-01-01T00:00:00');
      expect(model.updatedAt, '2023-06-01T00:00:00');
      expect(model.productApiUrl, 'https://api.example.com/product/101');
      expect(model.apiFeaturedImage, 'https://example.com/featured.jpg');
      expect(model.productColors.length, 2);
      expect(model.productColors.first.hexValue, '#FF5733');
      expect(model.productColors.first.colorName, 'Sunset Red');
      expect(model.rating, 4.5);

      // Test encoding back to JSON
      final encodedJson = model.toJson();
      expect(encodedJson['id'], '101');
      expect(encodedJson['product_colors'][1]['colour_name'], 'Berry Red');
      expect(encodedJson['rating'], 4.5);
    });
  });
}