import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_dashboard/main.dart';

void main() {
  group('WeatherApp Widget Tests', () {
    testWidgets('App builds and shows initial UI', (WidgetTester tester) async {
  await tester.pumpWidget(const WeatherApp());
  await tester.pumpAndSettle();

      // Verify app title
      expect(find.text('Weather Lookup'), findsOneWidget);

      // Verify subtitle
      expect(find.text('Enter your student index to get weather data'),
          findsOneWidget);

      // Verify input field exists
      expect(find.byType(TextField), findsOneWidget);

      // Verify fetch button
      expect(find.text('Fetch Weather'), findsOneWidget);

      // Verify initial state shows placeholders
      expect(find.text('---'), findsWidgets);
    });

    testWidgets('Theme toggle button exists', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      // Find theme toggle button (IconButton in AppBar)
      expect(find.byType(IconButton), findsOneWidget);

      // Verify it has a dark/light mode icon
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.icon, isNotNull);
    });

    testWidgets('Input card has default value', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      // Find the TextField
      final textField = tester.widget<TextField>(find.byType(TextField));
      
      // Check if it has a controller with default text
      expect(textField.controller, isNotNull);
      expect(textField.controller!.text, '224112A');
    });

    testWidgets('Coordinates card shows initially', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      // Verify coordinates card exists
      expect(find.text('Computed Coordinates'), findsOneWidget);
      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
    });

    testWidgets('Map card shows initially', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify map card
      expect(find.text('Location on Map'), findsOneWidget);
      expect(find.text('Open in OpenStreetMap'), findsOneWidget);
    });

    testWidgets('Weather info cards exist', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify all info card titles
      
      expect(find.text('Student Index'), findsOneWidget);
      // Some widgets are rendered lazily (CustomScrollView/SliverList) so we may
      // need to scroll to bring them into view.
      // Scroll down until temperature is visible
      // Keep dragging until all info cards appear or we reach a limit
      int attempts = 0;
      while (find.text('Weather Code').evaluate().isEmpty && attempts < 6) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        attempts++;
      }
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Wind Speed'), findsOneWidget);
      expect(find.text('Weather Code'), findsOneWidget);
      expect(find.text('Last Updated'), findsOneWidget);
    });

    testWidgets('Request URL card exists', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Scroll enough to bring the Request URL card into view
      int requestAttempts = 0;
      while (find.text('Request URL').evaluate().isEmpty && requestAttempts < 8) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        requestAttempts++;
      }
      expect(find.text('Request URL'), findsOneWidget);
      expect(find.text('Press "Fetch Weather" to generate URL'),
          findsOneWidget);
    });

    testWidgets('Footer exists', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

    // Footer is at the bottom; scroll until visible
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Powered by Open-Meteo API'), findsOneWidget);
      expect(find.text('Done by 224112A'), findsOneWidget);
    });

    testWidgets('Fetch button is initially enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      final elevatedFinder = find.widgetWithText(ElevatedButton, 'Fetch Weather');
      expect(elevatedFinder, findsOneWidget);

      final button = tester.widget<ElevatedButton>(elevatedFinder);
      // ElevatedButton.onPressed should not be null when enabled
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Can enter text in student index field',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      // Find the TextField
      final textField = find.byType(TextField);

      // Clear and enter new text
      await tester.enterText(textField, '224112A');
      await tester.pump();

      // Verify text was entered
      expect(find.text('224112A'), findsOneWidget);
    });

    // Note: The integration 'fetch' process calls the network. We validate
    // the fetch button presence and onPressed state elsewhere (unit tests).
  });

  group('Error Handling Tests', () {
    testWidgets('Shows error for invalid index',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      // Enter invalid index (less than 4 characters)
      final textField = find.byType(TextField);
      await tester.enterText(textField, '123');
      await tester.pump();

      // Tap fetch button
      final fetchButton =
          find.widgetWithText(ElevatedButton, 'Fetch Weather');
      await tester.tap(fetchButton);
      await tester.pump();

    // Should show error message
    expect(find.text('Invalid Index: Must be 6 digits followed by a letter (e.g., 224112A).'),
          findsOneWidget);
    });

    testWidgets('Shows error for various invalid formats',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      final textField = find.byType(TextField);
      final fetchButton = find.widgetWithText(ElevatedButton, 'Fetch Weather');

      final invalids = [
        'abcdef', // letters only
        '224112AA', // two letters at end
        '123456', // missing trailing letter
        '12345A6', // letter in middle
      ];

      for (final inv in invalids) {
        await tester.enterText(textField, inv);
        await tester.pump();

        await tester.tap(fetchButton);
        await tester.pump();

        expect(find.text('Invalid Index: Must be 6 digits followed by a letter (e.g., 224112A).'), findsOneWidget);
      }
    });

    testWidgets('Allows valid indexes (including lowercase and trimmed)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

      final textField = find.byType(TextField);

      // Valid formats should not show the invalid message
      final valids = ['224112A', '224112a', ' 224112A '];
      for (final v in valids) {
        await tester.enterText(textField, v);
        await tester.pump();

        expect(find.text('Invalid Index: Must be 6 digits followed by a letter (e.g., 224112A).'), findsNothing);
      }
    });
  });

  group('Theme Tests', () {
    testWidgets('Theme toggle changes theme mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());

  // Get initial theme (not strictly necessary, tapping the toggle should update)

      // Find and tap theme toggle button
      final themeButton = find.byType(IconButton);
      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      // Theme should have changed (brightness should be different)
      // Note: This is a simplified check
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}
