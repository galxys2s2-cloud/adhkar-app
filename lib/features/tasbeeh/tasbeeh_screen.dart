import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/arabesque_bg.dart';

// Tasbeeh state provider
final tasbeehCounterProvider = StateNotifierProvider<TasbeehNotifier, int>((ref) {
  return TasbeehNotifier();
});

class TasbeehNotifier extends StateNotifier<int> {
  TasbeehNotifier() : super(0);

  void increment() {
    if (state < AppConstants.tasbeehTarget) {
      state++;
      HapticFeedback.lightImpact();
    }
  }

  void reset() => state = 0;

  void setCount(int count) => state = count;
}

class TasbeehScreen extends ConsumerWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(tasbeehCounterProvider);
    final notifier = ref.read(tasbeehCounterProvider.notifier);
    final progress = counter / AppConstants.tasbeehTarget;
    final isComplete = counter >= AppConstants.tasbeehTarget;

    // Tasbeeh phrases
    final phrases = [
      {'text': 'سُبْحَانَ اللَّهِ', 'target': 33},
      {'text': 'الْحَمْدُ لِلَّهِ', 'target': 33},
      {'text': 'اللَّهُ أَكْبَرُ', 'target': 33},
      {'text': 'لَا إِلَهَ إِلَّا اللَّهُ', 'target': 1},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('التسبيح'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.reset(),
          ),
        ],
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Counter display
                GestureDetector(
                  onTap: () => notifier.increment(),
                  onLongPress: () => notifier.reset(),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          AppColors.navyDeep,
                          AppColors.gold,
                          AppColors.teal,
                          AppColors.navyDeep,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$counter',
                            style: AppTextStyles.counterNumber.copyWith(
                              color: AppColors.ivory,
                              fontSize: 72,
                            ),
                          ),
                          Text(
                            'من ${AppConstants.tasbeehTarget}',
                            style: AppTextStyles.goldLabel.copyWith(
                              color: AppColors.ivory.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط للعد — اضغط مطولاً للتصفير',
                  style: AppTextStyles.goldLabel.copyWith(
                    fontSize: 12,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 32),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.navyMedium,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isComplete ? '🔵 أتممت التسبيح!' : 'التقدم',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Phrase buttons
                Expanded(
                  child: ListView.separated(
                    itemCount: phrases.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      return _PhraseRow(
                        text: phrase['text'] as String,
                        target: phrase['target'] as int,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  final String text;
  final int target;

  const _PhraseRow({
    required this.text,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18,
                color: isDark ? AppColors.ivory : AppColors.navyDeep,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${target}x',
              style: AppTextStyles.goldLabel,
            ),
          ),
        ],
      ),
    );
  }
}
