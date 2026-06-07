import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../../data/models/adhkar_model.dart';
import '../../shared/widgets/arabesque_bg.dart';
import '../../shared/widgets/dua_card.dart';

class DuaaScreen extends ConsumerStatefulWidget {
  const DuaaScreen({super.key});

  @override
  ConsumerState<DuaaScreen> createState() => _DuaaScreenState();
}

class _DuaaScreenState extends ConsumerState<DuaaScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<DuaaModel>? _allDuaas;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DuaaModel> _filterDuaas(List<DuaaModel> items) {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return items.where((d) {
      if (d.arabic.toLowerCase().contains(q)) return true;
      if (d.translation?.toLowerCase().contains(q) ?? false) return true;
      if (d.transliteration?.toLowerCase().contains(q) ?? false) return true;
      return false;
    }).toList();
  }

  Future<void> _loadAllDuaas() async {
    if (_allDuaas != null) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adhkarRepositoryProvider);
      _allDuaas = await repo.loadDuaaList();
    } catch (_) {
      _allDuaas = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repository = ref.read(adhkarRepositoryProvider);
    final categories = repository.getDuaaCategories();

    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدعية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Search bar
              Padding(
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
                      hintText: '🔍  ابحث في الأدعية...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.gold,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.gold),
                              onPressed: () => _searchController.clear(),
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
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: isSearching
                    ? _buildSearchResults(isDark)
                    : _buildTabs(categories, repository, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(
    List<CategoryModel> categories,
    AdhkarRepository repository,
    bool isDark,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'سيتم إضافة الأدعية قريباً...',
          style: AppTextStyles.bodyLarge,
        ),
      );
    }

    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            dividerColor: AppColors.gold.withValues(alpha: 0.2),
            tabs: categories.map((cat) {
              return Tab(
                child: Text('${cat.icon} ${cat.name}'),
              );
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: categories.map((cat) {
                return _DuaaCategoryView(category: cat.key);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_allDuaas == null && !_isLoading) {
      _loadAllDuaas();
    }

    if (_isLoading || _allDuaas == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    final results = _filterDuaas(_allDuaas!);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 8),
          child: Text(
            '${results.length} نتيجة',
            style: AppTextStyles.goldLabel,
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (_, i) => DuaCard(duaa: results[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _DuaaCategoryView extends ConsumerWidget {
  final String category;

  const _DuaaCategoryView({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(adhkarRepositoryProvider);
    final duaList = repository.loadDuaaList();

    return FutureBuilder(
      future: duaList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('سيتم إضافة الأدعية قريباً...'),
          );
        }

        final filtered = snapshot.data!
            .where((d) => d.category == category)
            .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'سيتم إضافة الأدعية قريباً...',
              style: AppTextStyles.bodyLarge,
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return DuaCard(duaa: filtered[index]);
            },
          ),
        );
      },
    );
  }
}
