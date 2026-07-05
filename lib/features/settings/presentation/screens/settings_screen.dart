import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _handleMockAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop();
    _handleMockAction('Data backup successful. Saved to cloud.');
  }

  void _handleRestore() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data?'),
        content: const Text('This will overwrite your current local data with the latest cloud backup. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop();
      _handleMockAction('Data successfully restored from cloud.');
    }
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Privacy Policy'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: const [
                  Text(
                    'Your privacy is critically important to us.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'At BuildMate, we have a few fundamental principles:\n\n'
                    '• We are thoughtful about the personal information we ask you to provide and the personal information that we collect about you through the operation of our services.\n'
                    '• We store personal information for only as long as we have a reason to keep it.\n'
                    '• We aim for full transparency on how we gather, use, and share your personal information.\n\n'
                    'Note: This is a placeholder policy for demonstration purposes.',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        subtitle: 'App preferences and data management',
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SettingsSection(
            title: 'Preferences',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle app theme'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: _isDarkMode,
                onChanged: (val) {
                  setState(() => _isDarkMode = val);
                  _handleMockAction('Theme toggled (Mock UI implementation).');
                },
              ),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Alerts for expenses and tasks'),
                secondary: const Icon(Icons.notifications_outlined),
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SettingsSection(
            title: 'Data Management',
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Backup Data'),
                subtitle: const Text('Save your project data to the cloud'),
                onTap: _handleBackup,
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined),
                title: const Text('Restore Data'),
                subtitle: const Text('Recover data from your last backup'),
                onTap: _handleRestore,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SettingsSection(
            title: 'Support & About',
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Help & FAQ'),
                onTap: () => _handleMockAction('Help section coming soon!'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: _showPrivacyPolicy,
              ),
              const ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('About BuildMate'),
                subtitle: Text('Version 1.0.0 (Build 42)'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
