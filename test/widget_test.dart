import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab1/main.dart';

void phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shell shows tournaments and switches theme', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    expect(find.text('Tournaments'), findsWidgets);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final dark = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Dark'),
    );
    expect(dark.selected, isTrue);
  });

  testWidgets('list on a phone, grid on a tablet', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ListView), findsWidgets);
    expect(find.byType(GridView), findsNothing);

    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.5;
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('At least 3 characters'), findsOneWidget);
    expect(find.text('Pick a discipline'), findsOneWidget);
  });
}
