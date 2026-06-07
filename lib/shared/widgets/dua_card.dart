import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/adhkar_model.dart';

class DuaCard extends StatelessWidget {
  final DuaaModel duaa;

  const DuaCard({
    super.key,
    required this.duaa,
  });

  String get _shareText {
    final buffer = StringBuffer();
    buffer.writeln(duaa.arabic);
    if (duaa.translation != null && duaa.translation!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(duaa.translation);
    }
    buffer.writeln();
    buffer.writeln(AppConstants.appLink);
    return buffer.toString();
  }

  void _shareDuaa(BuildContext context) {
    Share.share(_shareText, subject: AppConstants.appName);
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: duaa.arabic));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ ✓'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Before/after label
          if (duaa.beforeAfter != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duaa.beforeAfter == 'before' ? 'قبل' : 'بعد',
                style: AppTextStyles.goldLabel.copyWith(
                  fontSize: 12,
                  color: AppColors.tealLight,
                ),
              ),
            ),
          // Text
          Text(
            duaa.arabic,
            style: isDark
                ? AppTextStyles.adhkarTextDark
                : AppTextStyles.adhkarText,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          const SizedBox(height: 12),
          // Reference + count + actions
          Row(
            children: [
              if (duaa.count > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${duaa.count} مرات',
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 12),
                  ),
                ),
              const Spacer(),
              Text(
                duaa.reference,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons: copy + share
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Copy
              _ActionButton(
                icon: Icons.copy,
                onPressed: () => _copyToClipboard(context),
                tooltip: 'نسخ',
              ),
              const SizedBox(width: 8),
              // Share
              _ActionButton(
                icon: Icons.share,
                onPressed: () => _shareDuaa(context),
                tooltip: 'مشاركة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.goldLight : AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
