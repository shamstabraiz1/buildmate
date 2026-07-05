import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/models/project_model.dart';
import '../providers/project_providers.dart';
import '../widgets/add_project_form.dart';

/// Screen to add a new project.
///
/// Uses [AddProjectForm] for data entry. Responsive layout: centered
/// constrained width on large screens, full width on compact screens.
class AddProjectScreen extends ConsumerWidget {
  const AddProjectScreen({this.project, super.key});

  final ProjectModel? project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isEditing = project != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEditing ? 'Edit Project' : 'Add New Project',
          subtitle: isEditing ? 'Update project details' : 'Create a new construction project',
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                child: AddProjectForm(
                  project: project,
                  onSave: (data) {
                    if (isEditing) {
                      final updatedProject = project!.copyWith(
                        name: data['name'],
                        clientName: data['clientName'],
                        location: data['location'],
                        budget: data['budget'],
                        startDate: data['startDate'],
                        endDate: data['completionDate'],
                        description: data['description'],
                      );
                      ref.read(projectsNotifierProvider.notifier).updateProject(updatedProject);
                    } else {
                      final newProject = ProjectModel.create(
                        name: data['name'],
                        clientName: data['clientName'],
                        location: data['location'],
                        budget: data['budget'],
                        startDate: data['startDate'],
                        endDate: data['completionDate'],
                        description: data['description'],
                      );
                      ref.read(projectsNotifierProvider.notifier).addProject(newProject);
                    }
                    debugPrint('AddProjectScreen onSave: called ${isEditing ? 'updateProject' : 'addProject'}');
                    
                    // Show success snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Project "${data['name']}" ${isEditing ? 'updated' : 'created'} successfully.'),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    
                    // Navigate back
                    Navigator.of(context).pop();
                  },
                  onCancel: () {
                    // Navigate back
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
