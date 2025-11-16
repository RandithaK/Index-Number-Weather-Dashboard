import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_dashboard/widgets/input_card.dart';
import 'package:weather_dashboard/widgets/coordinates_card.dart';
import 'package:weather_dashboard/widgets/info_card.dart';
import 'package:weather_dashboard/widgets/offline_banner.dart';
import 'package:weather_dashboard/widgets/error_card.dart';
import 'package:weather_dashboard/widgets/footer.dart';

void main() {
  group('InputCard Widget Tests', () {
    testWidgets('InputCard renders correctly', (WidgetTester tester) async {
      final controller = TextEditingController(text: '224112A');
      

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputCard(
              controller: controller,
              isLoading: false,
              onFetchPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Student Index'), findsOneWidget);
      expect(find.text('Fetch Weather'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('InputCard shows loading state', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputCard(
              controller: controller,
              isLoading: true,
              onFetchPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Fetch Weather'), findsNothing);
    });

    testWidgets('InputCard button calls callback', (WidgetTester tester) async {
      final controller = TextEditingController();
      bool fetchCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputCard(
              controller: controller,
              isLoading: false,
              onFetchPressed: () => fetchCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Fetch Weather'));
      expect(fetchCalled, true);
    });
  });

  group('CoordinatesCard Widget Tests', () {
    testWidgets('CoordinatesCard shows coordinates', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoordinatesCard(
              latitude: '7.20°',
              longitude: '83.10°',
            ),
          ),
        ),
      );

      expect(find.text('Computed Coordinates'), findsOneWidget);
      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
      expect(find.text('7.20°'), findsOneWidget);
      expect(find.text('83.10°'), findsOneWidget);
    });

    testWidgets('CoordinatesCard shows placeholders when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoordinatesCard(
              latitude: null,
              longitude: null,
            ),
          ),
        ),
      );

      expect(find.text('---'), findsNWidgets(2));
    });
  });

  group('InfoCard Widget Tests', () {
    testWidgets('InfoCard displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoCard(
              icon: Icons.thermostat_rounded,
              iconColor: Colors.red,
              title: 'Temperature',
              value: '25.5°C',
            ),
          ),
        ),
      );

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('25.5°C'), findsOneWidget);
      expect(find.byIcon(Icons.thermostat_rounded), findsOneWidget);
    });

    testWidgets('InfoCard respects custom value size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoCard(
              icon: Icons.schedule,
              iconColor: Colors.grey,
              title: 'Last Updated',
              value: '1/1/2024, 12:00:00 PM',
              valueSize: 13.0,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(
          find.text('1/1/2024, 12:00:00 PM'));
      expect(text.style?.fontSize, 13.0);
    });
  });

  group('OfflineBanner Widget Tests', () {
    testWidgets('OfflineBanner displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(),
          ),
        ),
      );

      expect(find.text('Showing cached data (offline)'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('ErrorCard Widget Tests', () {
    testWidgets('ErrorCard displays error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorCard(message: 'Network error occurred'),
          ),
        ),
      );

      expect(find.text('Network error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('Footer Widget Tests', () {
    testWidgets('Footer displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Footer(),
          ),
        ),
      );

      expect(find.text('Powered by Open-Meteo API'), findsOneWidget);
      expect(find.text('Done by 224112A'), findsOneWidget);
    });
  });

  group('Widget Theme Tests', () {
    testWidgets('Widgets adapt to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: CoordinatesCard(
              latitude: '7.20°',
              longitude: '83.10°',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CoordinatesCard), findsOneWidget);
    });

    testWidgets('Widgets adapt to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: CoordinatesCard(
              latitude: '7.20°',
              longitude: '83.10°',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CoordinatesCard), findsOneWidget);
    });
  });
}
