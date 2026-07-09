import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Amber warning banner shown when there are low-stock or out-of-stock materials.
class LowStockBanner extends StatelessWidget {
  const LowStockBanner({
    required this.count,
    this.onTap,
    super.key,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.cautionAmber.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
          border: Border.all(
            color: AppColors.cautionAmber.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.cautionAmber,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                count == 1
                    ? '1 material is low on stock'
                    : '$count materials are low on stock',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.cautionAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                'View',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.cautionAmber,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.cautionAmber,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.cautionAmber,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
