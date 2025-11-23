import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binsync/services/fcm_service.dart';
import 'package:binsync/services/pickup_schedule_service.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FCMService _fcmService = FCMService();
  final PickupScheduleService _scheduleService = PickupScheduleService();

  // Send pickup day reminder notification to user
  Future<void> sendPickupDayReminder(String userId, DateTime pickupDate,
      {String? time}) async {
    try {
      String message =
          'Today is garbage collection day! Please get your trash ready for pickup.';
      if (time != null && time.isNotEmpty) {
        message =
            'Garbage collection is scheduled at $time. Please get your trash ready!';
      }

      await _db.collection('notifications').add({
        'userId': userId,
        'title': 'Pickup Day Reminder',
        'message': message,
        'type': 'pickup_reminder',
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
        'pickupDate': Timestamp.fromDate(pickupDate),
      });

      // Send push notification
      await _fcmService.showImmediateNotification(
        title: 'Pickup Day Reminder',
        body: message,
        data: {'type': 'pickup_reminder'},
      );
    } catch (e) {
      throw Exception('Failed to send pickup reminder: $e');
    }
  }

  // Check and send notifications for today's schedules
  Future<void> checkAndSendScheduledNotifications() async {
    try {
      final todaySchedules = await _scheduleService.getTodaySchedules();

      for (var schedule in todaySchedules) {
        if (_scheduleService.shouldSendNotification(schedule)) {
          await sendPickupDayReminder(
            schedule.userId,
            DateTime.now(),
            time: schedule.time,
          );
        }
      }
    } catch (e) {
      print('Error checking scheduled notifications: $e');
    }
  }

  // Send notification when garbage is collected
  Future<void> sendGarbageCollectedNotification(
      String userId, String reportId) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': 'Garbage Collected',
        'message': 'Your reported garbage has been collected successfully!',
        'type': 'garbage_collected',
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
        'reportId': reportId,
      });
    } catch (e) {
      throw Exception('Failed to send collection notification: $e');
    }
  }

  // Schedule pickup day reminders (can be called by a scheduled function)
  Future<void> schedulePickupReminders() async {
    try {
      await checkAndSendScheduledNotifications();
    } catch (e) {
      throw Exception('Failed to schedule pickup reminders: $e');
    }
  }

  // Get unread notification count for user
  Stream<int> getUnreadNotificationCount(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final notificationsSnapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (var doc in notificationsSnapshot.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get all notifications for a user
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'message': data['message'] ?? '',
          'type': data['type'] ?? '',
          'read': data['read'] ?? false,
          'timestamp': data['timestamp'] as Timestamp?,
          'reportId': data['reportId'],
          'pickupDate': data['pickupDate'] as Timestamp?,
        };
      }).toList();
    });
  }
}
