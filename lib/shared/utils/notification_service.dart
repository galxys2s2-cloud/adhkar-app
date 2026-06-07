import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

/// Shows a daily notification for morning/evening adhkar
class NotificationService {
  /// Schedule morning adhkar notification
  static Future<void> scheduleMorningAdhkar() async {
    // Will be implemented with flutter_local_notifications
  }

  /// Schedule evening adhkar notification
  static Future<void> scheduleEveningAdhkar() async {
    // Will be implemented with flutter_local_notifications
  }

  /// Schedule random tasbeeh reminder
  static Future<void> scheduleRandomTasbeeh() async {
    // Will be implemented with flutter_local_notifications
  }

  /// Show a notification immediately
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Will be implemented with flutter_local_notifications
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    // Will be implemented with flutter_local_notifications
  }
}

/// Daily adhkar widget for the home screen
class DailyAdhkarWidget extends ConsumerWidget {
  const DailyAdhkarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check time of day to show morning or evening adhkar
    final hour = DateTime.now().hour;
    final isMorning = hour < 12;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMorning
              ? [AppColors.teal, AppColors.tealLight]
              : [AppColors.navyDeep, AppColors.navyMedium],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            isMorning ? '🌅' : '🌇',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMorning ? 'أذكار الصباح' : 'أذكار المساء',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMorning
                      ? '﴿ يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا ﴾'
                      : '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.7),
            size: 16,
          ),
        ],
      ),
    );
  }
}
