import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/status_chip.dart';
import '../../data/materials_dummy_data.dart';

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    required this.material,
    this.onTap,
    super.key,
  });

  final MaterialModel material;
  final VoidCallback? onTap;

  IconData _getCategoryIcon(MaterialCategory category) {
    switch (category) {
      case MaterialCategory.cement: return Icons.format_paint_outlined;
      case MaterialCategory.steel: return Icons.construction_outlined;
      case MaterialCategory.bricks: return Icons.widgets_outlined;
      case MaterialCategory.electrical: return Icons.electrical_services_outlined;
      case MaterialCategory.plumbing: return Icons.water_drop_outlined;
      case MaterialCategory.paint: return Icons.imagesearch_roller_outlined;
      case MaterialCategory.sand: return Icons.terrain_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final isLowStock = material.isLowStock;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isLowStock ? AppColors.dangerRed.withValues(alpha: 0.5) : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isLowStock ? 2 : 1,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Gradient
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isLowStock ? AppColors.dangerRed : colorScheme.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
                          ),
                          child: Icon(
                            _getCategoryIcon(material.category),
                            color: colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                MaterialsDummyData.categoryLabels[material.category] ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Stock',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              '${material.quantity.toStringAsFixed(material.quantity % 1 == 0 ? 0 : 2)} ${material.unit}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isLowStock ? AppColors.dangerRed : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        if (isLowStock)
                          const StatusChip(
                            label: 'Low Stock',
                            status: StatusChipType.danger,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
