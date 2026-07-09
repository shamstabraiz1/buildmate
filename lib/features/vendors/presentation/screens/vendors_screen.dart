import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/layout/custom_scaffold.dart';
import '../../data/models/vendor_model.dart';
import '../providers/vendor_providers.dart';
import '../../../materials/presentation/widgets/supplier_card.dart';
import 'add_vendor_screen.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<VendorModel> _filter(List<VendorModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((v) {
      return v.name.toLowerCase().contains(q) ||
          (v.contactPerson?.toLowerCase().contains(q) ?? false) ||
          (v.phone?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final vendorsState = ref.watch(vendorsNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: CustomScaffold(
        appBar: const CustomAppBar(
          title: 'Vendors',
          subtitle: 'Manage material suppliers',
          showBackButton: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddVendor(context),
          icon: const Icon(Icons.add_business_rounded),
          label: const Text('Add Vendor'),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: AppSearchBar(
                hintText: 'Search vendors…',
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
            ),

            Expanded(
              child: vendorsState.when(
                data: (vendors) {
                  final filtered = _filter(vendors);
                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: const Icon(
                          Icons.local_shipping_outlined, size: 64),
                      title: 'No vendors found',
                      message: _query.isNotEmpty
                          ? 'No vendors match your search.'
                          : 'Add your first vendor to get started.',
                      actionLabel: _query.isNotEmpty ? 'Clear Search' : null,
                      onActionPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl * 2,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final vendor = filtered[i];
                      return VendorCard(
                        vendor: vendor,
                        onTap: () => _openEditVendor(context, vendor),
                        onEdit: () => _openEditVendor(context, vendor),
                        onDelete: () => _confirmDelete(context, vendor),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: AppLoadingIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddVendor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddVendorScreen()),
    );
  }

  void _openEditVendor(BuildContext context, VendorModel vendor) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddVendorScreen(vendor: vendor)),
    );
  }

  void _confirmDelete(BuildContext context, VendorModel vendor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vendor'),
        content: Text(
          'Remove "${vendor.name}" from your vendor directory?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(vendorsNotifierProvider.notifier)
                  .deleteVendor(vendor.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
