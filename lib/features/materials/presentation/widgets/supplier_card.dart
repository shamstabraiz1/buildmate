import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../vendors/data/models/vendor_model.dart';

class VendorCard extends StatelessWidget {
  const VendorCard({
    required this.vendor,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final VendorModel vendor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  vendor.initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendor.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vendor.rating > 0) _buildRating(theme, vendor.rating),
                      ],
                    ),
                    if (vendor.contactPerson != null &&
                        vendor.contactPerson!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vendor.contactPerson!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (vendor.phone != null &&
                        vendor.phone!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 13, color: cs.primary),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            vendor.phone!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (onEdit != null || onDelete != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: cs.onSurfaceVariant),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            size: 18, color: cs.error),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRating(ThemeData theme, double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cautionAmber.withValues(alpha: 0.1),
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              size: 12, color: AppColors.cautionAmber),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.cautionAmber,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
