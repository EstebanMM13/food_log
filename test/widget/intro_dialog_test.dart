import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_food_log/data/local/app_database.dart';
import 'package:proyecto_food_log/presentation/providers/database_provider.dart';
import 'package:proyecto_food_log/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('checking "cargar restaurantes de prueba" seeds sample data', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a FoodLog'), findsOneWidget);

    await tester.tap(find.text('Cargar restaurantes de prueba'));
    await tester.tap(find.text('No volver a mostrar'));
    await tester.pumpAndSettle();

    expect(find.text('La Pepica'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('intro_dismissed'), isTrue);

    await db.close();
  });

  testWidgets('dialog does not reappear once dismissed, but stays reachable from the menu',
      (tester) async {
    SharedPreferences.setMockInitialValues({'intro_dismissed': true});
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a FoodLog'), findsNothing);

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acerca de FoodLog'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a FoodLog'), findsOneWidget);

    await db.close();
  });
}
