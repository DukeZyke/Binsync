import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectorStatsScreen extends StatefulWidget {
  const CollectorStatsScreen({super.key});

  @override
  State<CollectorStatsScreen> createState() => _CollectorStatsScreenState();
}

class _CollectorStatsScreenState extends State<CollectorStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyStats(userId),
            const SizedBox(height: 24),
            _buildWeeklyStats(userId),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('garbage_reports')
          .where('collectorId', isEqualTo: userId)
          .where('status', isEqualTo: 'collected')
          .where('collectedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('collectedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .snapshots(),
      builder: (context, collectedSnapshot) {
        final collected = collectedSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tracking_sessions')
              .doc('${userId}_${_getDateString(today)}')
              .snapshots(),
          builder: (context, trackingSnapshot) {
            final trackingData =
                trackingSnapshot.data?.data() as Map<String, dynamic>?;
            final distance = (trackingData?['distance'] ?? 0.0) / 1000; // km
            final duration = (trackingData?['duration'] ?? 0) / 3600.0; // hours

            return _buildStatsCard(
              'Daily Statistics',
              [
                _buildStatRow('Total Collected', '$collected bins'),
                _buildStatRow(
                    'Distance Traveled', '${distance.toStringAsFixed(2)} km'),
                _buildStatRow(
                    'Time Worked', '${duration.toStringAsFixed(2)} hrs'),
              ],
              Colors.green.shade50,
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyStats(String userId) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfWeekDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('garbage_reports')
          .where('collectorId', isEqualTo: userId)
          .where('status', isEqualTo: 'collected')
          .where('collectedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeekDay))
          .where('collectedAt', isLessThan: Timestamp.fromDate(endOfWeek))
          .snapshots(),
      builder: (context, collectedSnapshot) {
        final collected = collectedSnapshot.data?.docs.length ?? 0;

        return FutureBuilder<Map<String, dynamic>>(
          future: _calculateWeeklyTracking(userId, startOfWeekDay, endOfWeek),
          builder: (context, trackingSnapshot) {
            final distance = trackingSnapshot.data?['distance'] ?? 0.0;
            final duration = trackingSnapshot.data?['duration'] ?? 0.0;

            return _buildStatsCard(
              'Weekly Statistics',
              [
                _buildStatRow('Total Collected', '$collected bins'),
                _buildStatRow(
                    'Distance Traveled', '${distance.toStringAsFixed(2)} km'),
                _buildStatRow(
                    'Time Worked', '${duration.toStringAsFixed(2)} hrs'),
              ],
              Colors.blue.shade50,
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _calculateWeeklyTracking(
      String userId, DateTime start, DateTime end) async {
    double totalDistance = 0.0;
    double totalDuration = 0.0;

    final trackingSnapshot = await FirebaseFirestore.instance
        .collection('tracking_sessions')
        .where('collectorId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    for (var doc in trackingSnapshot.docs) {
      final data = doc.data();
      totalDistance += (data['distance'] ?? 0.0);
      totalDuration += (data['duration'] ?? 0.0).toDouble();
    }

    return {
      'distance': totalDistance / 1000, // km
      'duration': totalDuration / 3600, // hours
    };
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildStatsCard(String title, List<Widget> stats, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A86B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: stats,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isWarning ? Colors.red.shade700 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.red.shade700 : const Color(0xFF00A86B),
            ),
          ),
        ],
      ),
    );
  }
}
