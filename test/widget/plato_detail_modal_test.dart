import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/presentation/widgets/plato_detail_modal.dart';

void main() {
  Widget harness(Plato plato) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => mostrarDetallePlato(context, plato: plato, categoria: 'Entrantes'),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows dish name, score and category', (tester) async {
    final plato = Plato(
      id: 'p1',
      restauranteId: 'r1',
      tipo: 'Entrante',
      nombre: 'Patatas bravas',
      puntuacion: 8.5,
      comentario: 'Muy ricas, repetir.',
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(harness(plato));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Patatas bravas'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
    expect(find.text('Entrantes'), findsOneWidget);
    expect(find.text('Muy ricas, repetir.'), findsOneWidget);
  });

  testWidgets('shows the placeholder when the dish has no comment', (tester) async {
    final plato = Plato(
      id: 'p2',
      restauranteId: 'r1',
      tipo: 'Entrante',
      nombre: 'Sin comentario aún',
      puntuacion: 6,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(harness(plato));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Sin comentario todavía.'), findsOneWidget);
  });
}
