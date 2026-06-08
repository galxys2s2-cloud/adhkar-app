import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../../data/models/adhkar_model.dart';
import '../../shared/widgets/arabesque_bg.dart';
import '../../shared/widgets/adhkar_card.dart';
import '../../shared/widgets/staggered_animation.dart';

class AdhkarScreen extends ConsumerStatefulWidget {
  const AdhkarScreen({super.key});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<AdhkarModel>? _allAdhkar;
  bool _isLoading = false;

  late final AnimationController _searchAnimController;
  late final Animation<Offset> _searchSlide;
  late final Animation<double> _searchFade;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _searchSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _searchAnimController,
        curve: Curves.easeOut,
      ),
    );
    _searchFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _searchAnimController,
        curve: Curves.easeOut,
      ),
    );
    _searchAnimController.forward();

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AdhkarModel> _filterAdhkar(List<AdhkarModel> items) {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return items.where((a) {
      if (a.arabic.toLowerCase().contains(q)) return true;
      if (a.translation?.toLowerCase().contains(q) ?? false) return true;
      if (a.transliteration?.toLowerCase().contains(q) ?? false) return true;
      return false;
    }).toList();
  }

  Future<void> _loadAllAdhkar() async {
    if (_allAdhkar != null) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adhkarRepositoryProvider);
      _allAdhkar = await repo.loadAllAdhkar();
    } catch (_) {
      _allAdhkar = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.read(adhkarRepositoryProvider).getAdhkarCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _searchFade,
                  child: SlideTransition(
                    position: _searchSlide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: '🔍  ابحث في الأذكار...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.gold,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.gold),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.ivory : AppColors.navyDeep,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Content: search results or categories
              if (_searchQuery.isNotEmpty)
                _buildSearchResults()
              else ...[
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختر القسم',
                          style: AppTextStyles.headingLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'أذكار من الكتاب والسنة',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // Categories list
                SliverList.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return StaggeredAnimation(
                      index: index,
                      child: _buildCategoryItem(context, cat, isDark),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_allAdhkar == null && !_isLoading) {
      _loadAllAdhkar();
    }

    if (_isLoading || _allAdhkar == null) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
      );
    }

    final results = _filterAdhkar(_allAdhkar!);

    if (results.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.gold),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'حاول بكلمات أخرى',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 12),
              child: Text(
                '${results.length} نتيجة',
                style: AppTextStyles.goldLabel,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (_, i) => StaggeredAnimation(
                index: i,
                child: AdhkarCard(adhkar: results[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel cat, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(
          '${AppConstants.routeAdhkar}/${cat.key}',
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Text(cat.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 18,
                        color: isDark ? AppColors.ivory : AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat.description,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
