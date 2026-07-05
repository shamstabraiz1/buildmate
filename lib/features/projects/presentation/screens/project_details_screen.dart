import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/models/project_model.dart';
import '../providers/project_providers.dart';
import '../widgets/project_tabs.dart';
import 'add_project_screen.dart';

/// Screen to view the details of a specific project.
///
/// Uses [ProjectTabs] to display the project's summary, expenses,
/// labours, materials, reports, and gallery. Data is fetched from
/// Currently it uses the provided [projectId] to load data.
class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));

    return projectAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (ProjectModel? project) {
        if (project == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Project Not Found'),
        body: Center(
          child: EmptyStateWidget(
            icon: const Icon(Icons.error_outline_rounded),
            title: 'Project Not Found',
            message: 'The project you are looking for does not exist or has been removed.',
            actionLabel: 'Go Back',
            onActionPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

      return Scaffold(
        appBar: CustomAppBar(
          title: project.name,
          subtitle: project.location,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Project',
              onPressed: () {
                ref.read(projectsNotifierProvider.notifier).deleteProject(projectId);
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddProjectScreen(project: project),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: ProjectTabs(project: project),
        ),
      );
      },
    );
  }
}
