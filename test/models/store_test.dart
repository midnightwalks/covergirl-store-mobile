import 'package:flutter_test/flutter_test.dart';
import 'package:covergirlstore/models/store.dart';

void main() {
  group('Store model', () {
    test('should create Store instance with correct properties', () {
      final store = Store('My Store', 12.345, 67.890, '123 Main St');

      expect(store.name, 'My Store');
      expect(store.lat, 12.345);
      expect(store.lon, 67.890);
      expect(store.address, '123 Main St');
    });
  });
}