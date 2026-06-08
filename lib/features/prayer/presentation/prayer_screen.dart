import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/prayer_provider.dart';
import '../data/prayer_times_model.dart';
import 'widgets/countdown_widget.dart';
import 'widgets/prayer_card.dart';
import '../../../shared/widgets/arabesque_bg.dart';
import '../../../shared/widgets/staggered_animation.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingsAsync = ref.watch(prayerTimingsProvider);
    final city = ref.watch(selectedCityProvider);
    final methodName = ref.watch(selectedMethodNameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('🕌 $city'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Method selector
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune),
            tooltip: 'طريقة الحساب',
            onSelected: (method) {
              ref.read(selectedMethodProvider.notifier).state = method;
              ref.read(selectedMethodNameProvider.notifier).state =
                  _methodName(method);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 3, child: Text('Muslim World League')),
              const PopupMenuItem(value: 4, child: Text('Umm Al-Qura')),
              const PopupMenuItem(value: 5, child: Text('مصر')),
              const PopupMenuItem(value: 16, child: Text('ISNA')),
            ],
          ),
        ],
      ),
      body: ArabesqueBackground(
        child: timingsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (err, _) => _buildError(context, err.toString(), ref),
          data: (timings) => _buildContent(context, ref, timings, city, methodName, isDark),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PrayerTimesModel timings,
    String city,
    String methodName,
    bool isDark,
  ) {
    final now = ref.watch(currentTimeProvider).valueOrNull ?? DateTime.now();
    final nextPrayer = timings.nextPrayer(now);
    final remaining = timings.durationUntilNext(now);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () => ref.refresh(prayerTimingsProvider.future),
        child: CustomScrollView(
          slivers: [
            // Countdown section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (nextPrayer != null) ...[
                        Text(
                          'متبقي على ${nextPrayer.key}',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.gold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CountdownWidget(
                          remaining: remaining,
                          nextTime: nextPrayer.value,
                        ),
                      ] else ...[
                        Text(
                          'تمت جميع الصلوات — باكراً بإذن الله',
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Prayer times list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'مواقيت الصلاة',
                  style: AppTextStyles.headingLarge,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Prayer cards
            SliverList.separated(
              itemCount: timings.allTimes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final entry = timings.allTimes.entries.elementAt(index);
                final isNext = nextPrayer != null && entry.key == nextPrayer.key;

                return StaggeredAnimation(
                  index: index,
                  child: PrayerCard(
                    name: entry.key,
                    time: entry.value,
                    isNext: isNext,
                    isPast: nextPrayer != null && entry.key != nextPrayer.key &&
                        index < timings.allTimes.keys.toList().indexOf(nextPrayer.key),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // City selector button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton.icon(
                  onPressed: () => _showCityPicker(context, ref),
                  icon: const Icon(Icons.location_city),
                  label: const Text('تغيير المدينة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Method info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: Text(
                    'طريقة الحساب: $methodName',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل مواقيت الصلاة',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'تأكد من اتصالك بالإنترنت',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(prayerTimingsProvider.future),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context, WidgetRef ref) {
    final cities = [
      'بيروت', 'طرابلس', 'صيدا', 'صور', 'النبطية',
      'زحلة', 'جونيه', 'بعلبك', 'حلبا', 'الحدث',
      'جبيل', 'البترون', 'الشوف', 'عكار', 'الكورة',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر المدينة',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final isSelected = ref.watch(selectedCityProvider) == cities[i];
                    return ListTile(
                      title: Text(cities[i]),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.gold)
                          : null,
                      onTap: () {
                        ref.read(selectedCityProvider.notifier).state = cities[i];
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _methodName(int method) {
    switch (method) {
      case 3: return 'Muslim World League';
      case 4: return 'Umm Al-Qura';
      case 5: return 'مصر';
      case 16: return 'ISNA';
      default: return 'Muslim World League';
    }
  }
}
