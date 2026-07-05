import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LocalImageDisplay extends StatelessWidget {
  const LocalImageDisplay({
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(context),
      );
    } else {
      final file = File(imagePath);
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(context),
      );
    }
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
      ),
    );
  }
}
