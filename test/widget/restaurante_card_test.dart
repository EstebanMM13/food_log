import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/domain/models/restaurante_resumen.dart';
import 'package:proyecto_food_log/presentation/widgets/restaurante_card.dart';

void main() {
  testWidgets('RestauranteCard renders name, location, rating, tags and visits', (
    tester,
  ) async {
    var taps = 0;
    final resumen = RestauranteResumen(
      restaurante: Restaurante(
        id: 'r1',
        nombre: 'Camelot',
        ubicacion: 'Castellón de la Plana',
        visitas: 7,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
      puntuacionMedia: 8.5,
      tags: const [Tag(id: 't1', nombre: 'Español')],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: RestauranteCard(resumen: resumen, onTap: () => taps++),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camelot'), findsOneWidget);
    expect(find.text('Castellón de la Plana'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('7 visitas'), findsOneWidget);

    await tester.tap(find.byType(RestauranteCard));
    expect(taps, 1);
  });

  testWidgets('RestauranteCard falls back to a dash when there is no rating yet', (
    tester,
  ) async {
    final resumen = RestauranteResumen(
      restaurante: Restaurante(
        id: 'r2',
        nombre: 'Pekín',
        visitas: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
      puntuacionMedia: null,
      tags: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: RestauranteCard(resumen: resumen, onTap: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pekín'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });
}
