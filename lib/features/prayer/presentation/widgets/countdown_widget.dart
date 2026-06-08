import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Animated countdown widget that updates every second.
class CountdownWidget extends StatefulWidget {
  final Duration remaining;
  final DateTime nextTime;

  const CountdownWidget({
    super.key,
    required this.remaining,
    required this.nextTime,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
