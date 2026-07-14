import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/core/theme/app_theme.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/domain/tipo_plato.dart';
import 'package:proyecto_food_log/presentation/widgets/categoria_platos_section.dart';

void main() {
  Plato platoDe({required String nombre, String? comentario}) {
    return Plato(
      id: 'plato-$nombre',
      restauranteId: 'rest-1',
      tipo: 'Entrante',
      nombre: nombre,
      puntuacion: 8,
      comentario: comentario,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  Widget harness(Widget child) {
    return MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));
  }

  testWidgets('CategoriaPlatosSection renders its label and, expanded, its dishes', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        CategoriaPlatosSection(
          label: 'Entrantes',
          platos: [platoDe(nombre: 'Patatas bravas')],
          tipoParaAnadir: TipoPlato.entrante,
          restauranteId: 'rest-1',
          onEliminar: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entrantes'), findsOneWidget);
    expect(find.text('Patatas bravas'), findsNothing); // collapsed by default.

    await tester.tap(find.text('Entrantes'));
    await tester.pumpAndSettle();

    expect(find.text('Patatas bravas'), findsOneWidget);
  });

  testWidgets('tapping a dish row without a comment still opens the detail modal, showing the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        CategoriaPlatosSection(
          label: 'Entrantes',
          platos: [platoDe(nombre: 'Sin comentario aún')],
          tipoParaAnadir: TipoPlato.entrante,
          restauranteId: 'rest-1',
          onEliminar: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrantes'));
    await tester.pumpAndSettle();

    // The row's own comment button ("ver comentario") is enabled and opens
    // the modal even when there's nothing to show yet — the modal itself
    // handles the empty state as a placeholder, it isn't disabled up front.
    final botonComentario = find.byTooltip('Sin comentario');
    expect(botonComentario, findsOneWidget);

    await tester.tap(botonComentario);
    await tester.pumpAndSettle();

    expect(find.text('Sin comentario todavía.'), findsOneWidget);
  });
}
