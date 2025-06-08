import 'package:flutter_test/flutter_test.dart';
import 'package:covergirlstore/models/cart_item.dart'; // Ganti dengan path sesuai struktur project kamu

void main() {
  group('CartItem', () {
    test('should correctly assign values through constructor', () {
      final item = CartItem(
        id: '001',
        name: 'Lipstick Matte',
        imageUrl: 'https://example.com/image.jpg',
        price: '12.99',
        priceSign: '\$',
        quantity: 2,
        productColors: ['#FF5733', '#C70039'],
      );

      expect(item.id, '001');
      expect(item.name, 'Lipstick Matte');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.price, '12.99');
      expect(item.priceSign, '\$');
      expect(item.quantity, 2);
      expect(item.productColors, ['#FF5733', '#C70039']);
    });

    test('should use default quantity = 1 if not provided', () {
      final item = CartItem(
        id: '002',
        name: 'Mascara',
        imageUrl: 'https://example.com/mascara.jpg',
        price: '9.99',
        priceSign: '\$',
      );

      expect(item.quantity, 1);
    });

    test('copyWith should override only specified fields', () {
      final original = CartItem(
        id: '003',
        name: 'Eyeliner',
        imageUrl: 'https://example.com/eyeliner.jpg',
        price: '7.99',
        priceSign: '\$',
        quantity: 1,
        productColors: ['#000000'],
      );

      final updated = original.copyWith(
        quantity: 3,
        productColors: ['#FFFFFF'],
      );

      expect(updated.id, original.id); // unchanged
      expect(updated.name, original.name); // unchanged
      expect(updated.quantity, 3); // changed
      expect(updated.productColors, ['#FFFFFF']); // changed
    });
  });
}