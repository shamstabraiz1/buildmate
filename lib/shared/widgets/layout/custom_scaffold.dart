import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'custom_app_bar.dart';

/// Standard page scaffold with optional constrained content width.
class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    required this.body,
    this.title,
    this.subtitle,
    this.appBar,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.padding = const EdgeInsets.all(AppSpacing.screenPadding),
    this.maxContentWidth,
    this.safeArea = true,
    super.key,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final EdgeInsetsGeometry padding;
  final double? maxContentWidth;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: maxContentWidth == null
          ? body
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth!),
                child: body,
              ),
            ),
    );

    return Scaffold(
      appBar:
          appBar ??
          CustomAppBar(
            title: title,
            subtitle: subtitle,
            leading: leading,
            actions: actions,
            showBackButton: showBackButton,
          ),
      body: safeArea ? SafeArea(child: content) : content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
