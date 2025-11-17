// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:binsync/main.dart';

void main() {
  testWidgets('Binsync app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BinsyncApp());

    // Verify that the app title is present.
    expect(find.text('Binsync - Garbage Tracking'), findsOneWidget);

    // Verify that the map screen is loaded.
    expect(find.byType(MapScreen), findsOneWidget);
  });

  testWidgets('MapScreen has required UI elements', (WidgetTester tester) async {
    // Build the MapScreen widget.
    await tester.pumpWidget(
      const MaterialApp(
        home: MapScreen(),
      ),
    );

    // Verify app bar is present with title
    expect(find.text('Binsync - Garbage Tracking'), findsOneWidget);

    // Verify location reset button is present
    expect(find.byIcon(Icons.my_location), findsOneWidget);

    // Verify floating action buttons are present
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });
}
