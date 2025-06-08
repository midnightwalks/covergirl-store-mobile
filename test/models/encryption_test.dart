import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:covergirlstore/utils/encryption.dart'; // sesuaikan path

void main() {
  group('hashPassword', () {
    test('should return correct SHA-256 hash for given password', () {
      final password = 'mypassword123';
      
      // Expected hash dihitung manual, bisa juga pake code ini:
      final expectedHash = sha256.convert(utf8.encode(password)).toString();
      
      final result = hashPassword(password);
      
      expect(result, expectedHash);
    });

    test('should return different hash for different password', () {
      final password1 = 'password1';
      final password2 = 'password2';

      final hash1 = hashPassword(password1);
      final hash2 = hashPassword(password2);

      expect(hash1, isNot(hash2));
    });

    test('should return same hash for same password', () {
      final password = 'samepassword';

      final hash1 = hashPassword(password);
      final hash2 = hashPassword(password);

      expect(hash1, hash2);
    });
  });
}