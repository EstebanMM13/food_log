import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Small square/rounded preview of a restaurant/dish photo, used anywhere a
/// thumbnail is shown (home list, detail screen, dish rows). Falls back to a
/// discreet "Cuaderno"-themed placeholder — never a bare default Material
/// icon — when [fotoPath] is null or the file is missing.
class FotoThumbnail extends StatelessWidget {
  final String? fotoPath;
  final double size;
  final BorderRadius borderRadius;

  const FotoThumbnail({
    super.key,
    required this.fotoPath,
    this.size = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final path = fotoPath;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: path == null || path.isEmpty
            ? _placeholder(context)
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(context),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final accent = Theme.of(context).extension<BrandAccentColors>();
    return Center(
      child: Icon(
        Icons.restaurant_outlined,
        size: size * 0.5,
        color: accent?.secondary,
      ),
    );
  }
}
