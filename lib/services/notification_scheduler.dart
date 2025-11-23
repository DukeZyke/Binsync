import 'dart:async';
import 'package:binsync/services/notification_service.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance =
      NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  Timer? _timer;
  final NotificationService _notificationService = NotificationService();

  // Start checking schedules every 10 minutes
  void startScheduler() {
    // Check immediately
    _checkSchedules();

    // Then check every 10 minutes
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _checkSchedules();
    });
  }

  void stopScheduler() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkSchedules() async {
    try {
      print('Checking pickup schedules...');
      await _notificationService.checkAndSendScheduledNotifications();
    } catch (e) {
      print('Error checking schedules: $e');
    }
  }

  // Manual trigger for testing
  Future<void> checkNow() async {
    await _checkSchedules();
  }
}
