import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PickupSchedule {
  final String id;
  final String userId;
  final String day; // Monday, Tuesday, etc.
  final String? time; // Optional time (e.g., "10:00 AM")
  final bool isActive;
  final DateTime createdAt;

  PickupSchedule({
    required this.id,
    required this.userId,
    required this.day,
    this.time,
    this.isActive = true,
    required this.createdAt,
  });

  factory PickupSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PickupSchedule(
      id: doc.id,
      userId: data['userId'] as String,
      day: data['day'] as String,
      time: data['time'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'day': day,
      'time': time,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PickupScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new pickup schedule
  Future<String> addSchedule({
    required String day,
    String? time,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final schedule = PickupSchedule(
        id: '',
        userId: user.uid,
        day: day,
        time: time,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final docRef =
          await _db.collection('pickup_schedules').add(schedule.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add schedule: $e');
    }
  }

  // Get user's pickup schedules
  Stream<List<PickupSchedule>> getUserSchedules() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('pickup_schedules')
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final schedules = snapshot.docs
          .map((doc) => PickupSchedule.fromFirestore(doc))
          .toList();

      // Sort by day of week in memory
      final dayOrder = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
      };

      schedules.sort(
          (a, b) => (dayOrder[a.day] ?? 8).compareTo(dayOrder[b.day] ?? 8));

      return schedules;
    });
  }

  // Get all active schedules (for notification scheduling)
  Future<List<PickupSchedule>> getAllActiveSchedules() async {
    try {
      final snapshot = await _db
          .collection('pickup_schedules')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PickupSchedule.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get schedules: $e');
    }
  }

  // Update schedule
  Future<void> updateSchedule(String scheduleId,
      {String? day, String? time}) async {
    try {
      final updates = <String, dynamic>{};
      if (day != null) updates['day'] = day;
      if (time != null) updates['time'] = time;

      await _db.collection('pickup_schedules').doc(scheduleId).update(updates);
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete schedule (soft delete)
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _db.collection('pickup_schedules').doc(scheduleId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // Get schedules for today
  Future<List<PickupSchedule>> getTodaySchedules() async {
    final now = DateTime.now();
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final today = days[now.weekday % 7];

    try {
      final snapshot = await _db
          .collection('pickup_schedules')
          .where('day', isEqualTo: today)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PickupSchedule.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get today schedules: $e');
    }
  }

  // Check if notification should be sent
  bool shouldSendNotification(PickupSchedule schedule) {
    final now = DateTime.now();
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final today = days[now.weekday % 7];

    // Check if today matches the schedule day
    if (schedule.day != today) return false;

    // If no specific time, send notification in the morning (8 AM)
    if (schedule.time == null || schedule.time!.isEmpty) {
      return now.hour == 8 && now.minute < 10;
    }

    // Parse time and check if it's 1 hour before
    try {
      final timeParts = schedule.time!.split(' ');
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      // Convert to 24-hour format
      if (timeParts.length > 1 &&
          timeParts[1].toUpperCase() == 'PM' &&
          hour != 12) {
        hour += 12;
      } else if (timeParts.length > 1 &&
          timeParts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      // Calculate 1 hour before
      final notificationTime =
          DateTime(now.year, now.month, now.day, hour, minute)
              .subtract(const Duration(hours: 1));

      // Check if current time matches notification time (within 10 minutes window)
      final diff = now.difference(notificationTime).inMinutes.abs();
      return diff < 10;
    } catch (e) {
      print('Error parsing time: $e');
      return false;
    }
  }
}
