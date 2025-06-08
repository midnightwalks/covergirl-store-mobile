import 'package:flutter_test/flutter_test.dart';
import 'package:covergirlstore/models/notification_item.dart';

void main() {
  group('NotificationItem', () {
    test('should create instance correctly', () {
      final now = DateTime.now();
      final item = NotificationItem(
        message: 'Pembayaran berhasil',
        timestamp: now,
        paymentMethod: 'GoPay',
      );

      expect(item.message, 'Pembayaran berhasil');
      expect(item.timestamp, now);
      expect(item.paymentMethod, 'GoPay');
    });
  });
}