import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Animated countdown widget that updates every second.
class CountdownWidget extends StatefulWidget {
  final Duration remaining;
  final DateTime nextTime;
  final String nextPrayerName;

  const CountdownWidget({
    super.key,
    required this.remaining,
    required this.nextTime,
    required this.nextPrayerName,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = widget.nextTime.difference(now);
      if (diff.isNegative) {
        setState(() => _remaining = Duration.zero);
        _timer?.cancel();
      } else {
        setState(() => _remaining = diff);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  IconData _resolvePrayerIcon(String name) {
    return switch (name) {
      'الفجر' => Icons.wb_twilight,
      'الظهر' => Icons.wb_sunny_outlined,
      'العصر' => Icons.cloud,
      'المغرب' => Icons.nights_stay,
      'العشاء' => Icons.nightlight,
      _ => Icons.access_time,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _resolvePrayerIcon(widget.nextPrayerName),
            size: 64,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'متبقي على ${widget.nextPrayerName}',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.gold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _format(_remaining),
          style: AppTextStyles.counterNumber.copyWith(fontSize: 48),
        ),
        const SizedBox(height: 4),
        Text(
          'ساعة : دقيقة : ثانية',
          style: AppTextStyles.goldLabel.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
