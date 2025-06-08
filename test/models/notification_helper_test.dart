import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:covergirlstore/models/notification_helper.dart';

// Generate mock
@GenerateMocks([FlutterLocalNotificationsPlugin])
import 'notification_helper_test.mocks.dart';

void main() {
  group('showNotification', () {
    test('should call show with correct params', () async {
      final mockPlugin = MockFlutterLocalNotificationsPlugin();

      when(mockPlugin.show(any, any, any, any))
          .thenAnswer((_) async => null);

      await showNotification(
          title: 'title', body: 'body', plugin: mockPlugin);

      verify(mockPlugin.show(any, any, any, any)).called(1);
    });
  });
}