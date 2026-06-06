import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../../shared/widgets/arabesque_bg.dart';
import '../../shared/widgets/dua_card.dart';

class DuaaScreen extends ConsumerWidget {
  const DuaaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(adhkarRepositoryProvider);
    final categories = repository.getDuaaCategories();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأدعية'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.lightTextSecondary,
            dividerColor: AppColors.gold.withValues(alpha: 0.2),
            tabs: categories.map((cat) {
              return Tab(
                child: Text('${cat.icon} ${cat.name}'),
              );
            }).toList(),
          ),
        ),
        body: ArabesqueBackground(
          child: TabBarView(
            children: categories.map((cat) {
              return _DuaaCategoryView(category: cat.key);
            }).toList(),
          ),
        ),
      ),
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
