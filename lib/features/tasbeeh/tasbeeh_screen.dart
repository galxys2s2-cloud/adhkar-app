import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/arabesque_bg.dart';
import '../../shared/widgets/staggered_animation.dart';

// ---- Tasbeeh state model ----

class TasbeehState {
  final int currentPhraseIndex;
  final List<int> progress;
  final List<int> targets;

  const TasbeehState({
    this.currentPhraseIndex = 0,
    required this.progress,
    required this.targets,
  });

  /// Total target sum across all phrases
  int get totalTarget => targets.fold(0, (a, b) => a + b);

  /// Total completed count across all phrases
  int get totalCompleted => progress.fold(0, (a, b) => a + b);

  /// Overall fraction (0.0–1.0)
  double get totalProgress =>
      totalTarget > 0 ? totalCompleted / totalTarget : 0.0;

  /// Whether EVERY phrase has reached its target
  bool get isComplete => totalCompleted >= totalTarget;

  /// The current phrase's target
  int get currentTarget => currentPhraseIndex < targets.length
      ? targets[currentPhraseIndex]
      : 1;

  /// The current phrase's progress value
  int get currentProgress => currentPhraseIndex < progress.length
      ? progress[currentPhraseIndex]
      : 0;

  /// Fraction for the current phrase circle (0.0–1.0)
  double get currentFraction =>
      currentTarget > 0 ? currentProgress / currentTarget : 0.0;

  /// Whether the current phrase has reached its own target
  bool get currentComplete => currentProgress >= currentTarget;

  /// Whether a specific phrase index is completed
  bool isPhraseComplete(int index) =>
      index < progress.length && index < targets.length
          ? progress[index] >= targets[index]
          : false;
}

// ---- Tasbeeh notifier ----

final tasbeehCounterProvider =
    StateNotifierProvider<TasbeehNotifier, TasbeehState>((ref) {
  return TasbeehNotifier();
});

class TasbeehNotifier extends StateNotifier<TasbeehState> {
  static const List<int> defaultTargets = [33, 33, 33, 1];

  TasbeehNotifier()
      : super(TasbeehState(
          progress: List.filled(defaultTargets.length, 0),
          targets: defaultTargets,
        ));

  void increment() {
    if (state.isComplete) return; // all done — no-op

    final newProgress = [...state.progress];
    int newIndex = state.currentPhraseIndex;

    // Bump current phrase
    if (newProgress[newIndex] < state.targets[newIndex]) {
      newProgress[newIndex]++;
      HapticFeedback.lightImpact();
    }

    // Auto-advance: if current phrase is now complete, move to next
    if (newProgress[newIndex] >= state.targets[newIndex]) {
      // Find the next incomplete phrase
      int next = newIndex + 1;
      while (next < state.targets.length && newProgress[next] >= state.targets[next]) {
        next++;
      }
      if (next < state.targets.length) {
        newIndex = next;
      }
      // If no next incomplete phrase, stay on last index — state will be isComplete
    }

    state = TasbeehState(
      currentPhraseIndex: newIndex,
      progress: newProgress,
      targets: state.targets,
    );
  }

  void reset() {
    state = TasbeehState(
      currentPhraseIndex: 0,
      progress: List.filled(state.targets.length, 0),
      targets: state.targets,
    );
  }
}

// ---- Screen UI ----

class TasbeehScreen extends ConsumerWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbeeh = ref.watch(tasbeehCounterProvider);
    final notifier = ref.read(tasbeehCounterProvider.notifier);

    // Phrase definitions (tied to the state targets)
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
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/tasbeeh/stats'),
          ),
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
                // Circular counter display
                _PulseCounter(
                  onTap: () => notifier.increment(),
                  onLongPress: () => notifier.reset(),
                  gradient: const SweepGradient(
                    colors: [
                      AppColors.navyDeep,
                      AppColors.gold,
                      AppColors.teal,
                      AppColors.navyDeep,
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tasbeeh.currentProgress}',
                        style: AppTextStyles.counterNumber.copyWith(
                          color: AppColors.ivory,
                          fontSize: 72,
                        ),
                      ),
                      Text(
                        'من ${tasbeeh.currentTarget}',
                        style: AppTextStyles.goldLabel.copyWith(
                          color: AppColors.ivory.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
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
                // Total progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: tasbeeh.totalProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.navyMedium,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tasbeeh.isComplete ? '🔵 أتممت التسبيح!' : 'التقدم',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Phrase rows
                Expanded(
                  child: ListView.separated(
                    itemCount: phrases.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      return StaggeredAnimation(
                        index: index,
                        child: _PhraseRow(
                          text: phrase['text'] as String,
                          target: phrase['target'] as int,
                          progress: tasbeeh.progress[index],
                          isActive: index == tasbeeh.currentPhraseIndex,
                          isCompleted: tasbeeh.isPhraseComplete(index),
                        ),
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

// ---- Pulse counter widget ----

class _PulseCounter extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Gradient gradient;
  final Widget child;

  const _PulseCounter({
    required this.onTap,
    required this.onLongPress,
    required this.gradient,
    required this.child,
  });

  @override
  State<_PulseCounter> createState() => _PulseCounterState();
}

class _PulseCounterState extends State<_PulseCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAlphaAnimation;
  late final Animation<double> _blurAnimation;
  late final Animation<double> _spreadAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAlphaAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.3), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _blurAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 30.0, end: 40.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 40.0, end: 30.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _spreadAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 5.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            onLongPress: widget.onLongPress,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.gradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: _glowAlphaAnimation.value),
                    blurRadius: _blurAnimation.value,
                    spreadRadius: _spreadAnimation.value,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: Center(child: widget.child),
    );
  }
}

// ---- Phrase row widget ----

class _PhraseRow extends StatelessWidget {
  final String text;
  final int target;
  final int progress;
  final bool isActive;
  final bool isCompleted;

  const _PhraseRow({
    required this.text,
    required this.target,
    required this.progress,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor;
    if (isCompleted) {
      borderColor = AppColors.tealLight;
    } else if (isActive) {
      borderColor = AppColors.gold;
    } else {
      borderColor = AppColors.gold.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isActive || isCompleted ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Active indicator
          if (isActive && !isCompleted)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
              ),
            ),
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '✅',
                style: TextStyle(fontSize: 14),
              ),
          ),
          // Phrase text
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18,
                color: isCompleted
                    ? AppColors.tealLight
                    : isActive
                        ? AppColors.gold
                        : (isDark ? AppColors.ivory : AppColors.navyDeep),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Progress badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.tealLight.withValues(alpha: 0.2)
                  : AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isCompleted ? '✅ $target' : '$progress/$target',
              style: AppTextStyles.goldLabel.copyWith(
                color: isCompleted ? AppColors.tealLight : AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
