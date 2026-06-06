import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../../shared/widgets/adhkar_card.dart';
import '../../shared/widgets/arabesque_bg.dart';

class AdhkarDetailScreen extends ConsumerWidget {
  final String category;

  const AdhkarDetailScreen({
    super.key,
    required this.category,
  });

  String get _title {
    switch (category) {
      case 'morning':
        return 'أذكار الصباح';
      case 'evening':
        return 'أذكار المساء';
      case 'after_prayer':
        return 'أذكار بعد الصلاة';
      default:
        return 'الأذكار';
    }
  }

  String get _icon {
    switch (category) {
      case 'morning':
        return '🌅';
      case 'evening':
        return '🌇';
      case 'after_prayer':
        return '🕌';
      default:
        return '📖';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(adhkarRepositoryProvider);
    final adhkarList = repository.loadByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('$_icon $_title'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ArabesqueBackground(
        child: FutureBuilder(
          future: adhkarList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ في تحميل الأذكار',
                  style: AppTextStyles.bodyLarge,
                ),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'سيتم إضافة الأذكار قريباً...',
                  style: AppTextStyles.bodyLarge,
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final adhkar = items[index];
                  return AdhkarCard(adhkar: adhkar);
                },
              ),
            );
          },
        ),
      ),
    );
  }

}
