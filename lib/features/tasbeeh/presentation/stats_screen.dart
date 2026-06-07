import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/arabesque_bg.dart';
import '../data/tasbeeh_repository.dart';

// Tab index provider
final statsTabProvider = StateProvider<int>((ref) => 0);

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(statsTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.ivory : AppColors.navyDeep;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات التسبيح'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'اليوم',
                        isActive: selectedTab == 0,
                        onTap: () => ref.read(statsTabProvider.notifier).state = 0,
                      ),
                      _TabButton(
                        label: 'الأسبوع',
                        isActive: selectedTab == 1,
                        onTap: () => ref.read(statsTabProvider.notifier).state = 1,
                      ),
                      _TabButton(
                        label: 'الشهر',
                        isActive: selectedTab == 2,
                        onTap: () => ref.read(statsTabProvider.notifier).state = 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: switch (selectedTab) {
                    0 => _TodayView(textColor: textColor, surfaceColor: surfaceColor),
                    1 => _WeekView(textColor: textColor, surfaceColor: surfaceColor),
                    2 => _MonthView(textColor: textColor, surfaceColor: surfaceColor),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: AppColors.gold.withValues(alpha: 0.5))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 14,
              color: isActive ? AppColors.gold : AppColors.ivory.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────── Today View ───────────
class _TodayView extends StatelessWidget {
  final Color textColor;
  final Color surfaceColor;

  const _TodayView({required this.textColor, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: tasbeehRepository.getTodayTotal(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
          children: [
            _StatCard(
              title: 'تسبيحات اليوم',
              value: '$count',
              icon: Icons.touch_app,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            const SizedBox(height: 16),
            _StatCard(
              title: 'الهدف',
              value: '100',
              subtitle: count >= 100 ? '✅ تم الهدف' : '${100 - count} متبقّية',
              icon: Icons.flag,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      count >= 100 ? Icons.check_circle : Icons.radio_button_off,
                      size: 64,
                      color: count >= 100 ? AppColors.tealLight : AppColors.gold.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      count >= 100 ? 'أحسنت اليوم!' : 'واصل التسبيح...',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────── Week View ───────────
class _WeekView extends StatelessWidget {
  final Color textColor;
  final Color surfaceColor;

  const _WeekView({required this.textColor, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: tasbeehRepository.getWeeklyStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final stats = snapshot.data!;
        final total = stats.values.fold(0, (a, b) => a + b);
        final maxVal = stats.values.isEmpty ? 1 : stats.values.reduce((a, b) => a > b ? a : b);
        final safeMax = maxVal < 1 ? 1 : maxVal;

        return Column(
          children: [
            _StatCard(
              title: 'إجمالي الأسبوع',
              value: '$total',
              icon: Icons.calendar_view_week,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'تقدم الأسبوع',
                      style: AppTextStyles.goldLabel.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: _BarChartPainter(
                          data: stats,
                          maxValue: safeMax.toDouble(),
                          barColor: AppColors.gold,
                          textColor: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────── Month View ───────────
class _MonthView extends StatelessWidget {
  final Color textColor;
  final Color surfaceColor;

  const _MonthView({required this.textColor, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: tasbeehRepository.getMonthlyStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final stats = snapshot.data!;
        final total = stats.values.fold(0, (a, b) => a + b);
        final maxVal = stats.values.isEmpty ? 1 : stats.values.reduce((a, b) => a > b ? a : b);
        final safeMax = maxVal < 1 ? 1 : maxVal;

        return Column(
          children: [
            _StatCard(
              title: 'إجمالي الشهر',
              value: '$total',
              icon: Icons.calendar_month,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'تقدم الشهر',
                      style: AppTextStyles.goldLabel.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: _BarChartPainter(
                          data: stats,
                          maxValue: safeMax.toDouble(),
                          barColor: AppColors.tealLight,
                          textColor: textColor,
                          labelEvery: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────── Shared Widgets ───────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color surfaceColor;
  final Color textColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 28,
                    color: AppColors.gold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.tealLight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────── CustomPainter Bar Chart ───────────
class _BarChartPainter extends CustomPainter {
  final Map<String, int> data;
  final double maxValue;
  final Color barColor;
  final Color textColor;
  final int labelEvery;

  _BarChartPainter({
    required this.data,
    required this.maxValue,
    required this.barColor,
    required this.textColor,
    this.labelEvery = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final entries = data.entries.toList();
    if (entries.isEmpty) return;

    const padding = 24.0;
    const bottomPadding = 28.0;
    final availableWidth = size.width - (padding * 2);
    final barWidth = availableWidth / entries.length;
    final maxBarHeight = size.height - bottomPadding - padding;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = textColor.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = padding + (maxBarHeight * i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Draw bars
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final ratio = entry.value / maxValue;
      final barHeight = ratio * maxBarHeight;
      final x = padding + (i * barWidth);
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + barWidth * 0.15,
          padding + maxBarHeight - barHeight,
          barWidth * 0.7,
          barHeight,
        ),
        const Radius.circular(4),
      );

      final paint = Paint()
        ..color = barColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(barRect, paint);

      // Top value label for non-zero bars
      if (entry.value > 0 && barHeight > 16) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${entry.value}',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        );
        textPainter.layout(minWidth: 0, maxWidth: barWidth);
        textPainter.paint(
          canvas,
          Offset(
            x + (barWidth - textPainter.width) / 2,
            padding + maxBarHeight - barHeight - 14,
          ),
        );
      }

      // Bottom date label
      final date = DateTime.parse(entry.key);
      final labelText = DateFormat('d').format(date);
      if (i % labelEvery == 0 || i == entries.length - 1) {
        final labelPainter = TextPainter(
          text: TextSpan(
            text: labelText,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        );
        labelPainter.layout(minWidth: 0, maxWidth: barWidth);
        labelPainter.paint(
          canvas,
          Offset(
            x + (barWidth - labelPainter.width) / 2,
            padding + maxBarHeight + 6,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
