import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/arabesque_bg.dart';
import '../data/tasbeeh_repository.dart';

// Selected dhikr provider
final selectedDhikrProvider = StateProvider<String>((ref) => 'سُبْحَانَ اللَّهِ');

// Tasbeeh state provider
final tasbeehCounterProvider = StateNotifierProvider<TasbeehNotifier, int>((ref) {
  return TasbeehNotifier(ref);
});

class TasbeehNotifier extends StateNotifier<int> {
  final Ref _ref;

  TasbeehNotifier(this._ref) : super(0) {
    _loadDailyAccumulated();
  }

  Future<void> _loadDailyAccumulated() async {
    // Check midnight reset
    final didReset = await tasbeehRepository.checkAndResetDaily();
    if (didReset) {
      state = 0;
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final acc = await tasbeehRepository.getTotalForDate(today);
    // If there is history for today, start from zero (history is already saved)
    // But if there is only accumulated, resume it.
    // For simplicity: we keep accumulated in a separate key that gets cleared on saveSession.
    // Here we just show current session count as state.
  }

  void increment() {
    if (state < AppConstants.tasbeehTarget) {
      state++;
      HapticFeedback.lightImpact();
      _persistAccumulated();
    }
  }

  void reset() => state = 0;

  void setCount(int count) => state = count;

  Future<void> _persistAccumulated() async {
    final dhikr = _ref.read(selectedDhikrProvider);
    await tasbeehRepository.accumulateDaily(count: state, dhikr: dhikr);
  }

  /// Save current session to history and clear accumulated
  Future<void> saveSession() async {
    if (state == 0) return;
    final dhikr = _ref.read(selectedDhikrProvider);
    await tasbeehRepository.saveSession(count: state, dhikr: dhikr);
    await tasbeehRepository.clearDailyAccumulated(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    state = 0;
  }
}

class TasbeehScreen extends ConsumerStatefulWidget {
  const TasbeehScreen({super.key});

  @override
  ConsumerState<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends ConsumerState<TasbeehScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkDailyReset();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Save session when leaving screen
    ref.read(tasbeehCounterProvider.notifier).saveSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Save when app goes to background
      ref.read(tasbeehCounterProvider.notifier).saveSession();
    }
  }

  Future<void> _checkDailyReset() async {
    final didReset = await tasbeehRepository.checkAndResetDaily();
    if (didReset && mounted) {
      ref.read(tasbeehCounterProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(tasbeehCounterProvider);
    final notifier = ref.read(tasbeehCounterProvider.notifier);
    final selectedDhikr = ref.watch(selectedDhikrProvider);
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
          onPressed: () {
            notifier.saveSession();
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'إحصائيات',
            onPressed: () {
              notifier.saveSession();
              context.push(AppConstants.routeTasbeehStats);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تصفير',
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
                // Selected dhikr chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    selectedDhikr,
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 16),
                  ),
                ),
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
                // Save button (visible when > 0)
                if (counter > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await notifier.saveSession();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ تم حفظ الجلسة'),
                                duration: Duration(seconds: 2),
                                backgroundColor: AppColors.teal,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('حفظ الجلسة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                          foregroundColor: AppColors.gold,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                // Phrase buttons
                Expanded(
                  child: ListView.separated(
                    itemCount: phrases.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      final isSelected = selectedDhikr == phrase['text'];
                      return _PhraseRow(
                        text: phrase['text'] as String,
                        target: phrase['target'] as int,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(selectedDhikrProvider.notifier).state =
                              phrase['text'] as String;
                        },
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
  final bool isSelected;
  final VoidCallback onTap;

  const _PhraseRow({
    required this.text,
    required this.target,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.5)
                : AppColors.gold.withValues(alpha: 0.15),
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
                color: isSelected
                    ? AppColors.gold.withValues(alpha: 0.25)
                    : AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${target}x',
                style: AppTextStyles.goldLabel.copyWith(
                  color: isSelected ? AppColors.goldLight : AppColors.gold,
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle, color: AppColors.gold, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
