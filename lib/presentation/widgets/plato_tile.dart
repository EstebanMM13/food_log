import 'package:flutter/material.dart';

import '../../data/local/app_database.dart';
import 'rating_badge.dart';

/// One dish row in the restaurant detail screen.
class PlatoTile extends StatelessWidget {
  final Plato plato;
  final VoidCallback? onTap;

  const PlatoTile({super.key, required this.plato, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(plato.nombre),
      subtitle: Text(plato.tipo),
      trailing: RatingBadge(puntuacion: plato.puntuacion),
    );
  }
}
