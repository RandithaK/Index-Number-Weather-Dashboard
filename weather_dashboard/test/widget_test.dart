// This is a basic Flutter widget test for the WeatherApp.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the main app file. Make sure the package name 'weather_dashboard'
// matches your pubspec.yaml 'name' field.
import 'package:weather_dashboard/main.dart';

void main() {
  testWidgets('WeatherApp builds and shows header', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // Verify that our app shows the title.
    expect(find.text('Weather Lookup'), findsOneWidget);

    // Verify that the app shows the subtitle.
    expect(
        find.text('Enter your student index to get weather data'), findsOneWidget);

    // Verify the "Fetch Weather" button is present.
    expect(find.text('Fetch Weather'), findsOneWidget);
  });
}