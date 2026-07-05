import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/materials_dummy_data.dart';
import '../widgets/supplier_card.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final suppliers = MaterialsDummyData.suppliers;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Suppliers Directory',
        subtitle: 'Manage material vendors',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: suppliers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return SupplierCard(
            supplier: supplier,
            onTap: () {
              // TODO: View Supplier Details
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add Supplier
        },
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Add Supplier'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
