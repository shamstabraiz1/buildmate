import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Screen Selector'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNavButton(context, 'Splash', AppRoutes.splash),
          _buildNavButton(context, 'Login', AppRoutes.login),
          _buildNavButton(context, 'Dashboard', AppRoutes.dashboard),
          _buildNavButton(context, 'Projects', AppRoutes.projects),
          _buildNavButton(context, 'Project Details (Dummy ID)', AppRoutes.projectDetails.replaceFirst(':projectId', 'dummy_123')),
          _buildNavButton(context, 'Expenses', AppRoutes.expenses),
          _buildNavButton(context, 'Labour', AppRoutes.labour),
          _buildNavButton(context, 'Materials', AppRoutes.materials),
          _buildNavButton(context, 'Reports', AppRoutes.reports),
          _buildNavButton(context, 'Settings', AppRoutes.settings),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FilledButton.tonal(
        onPressed: () => context.push(route),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
