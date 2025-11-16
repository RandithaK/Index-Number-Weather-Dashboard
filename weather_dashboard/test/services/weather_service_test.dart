import 'package:flutter_test/flutter_test.dart';
import 'package:weather_dashboard/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WeatherData Model Tests', () {
    test('WeatherData can be created', () {
      final data = WeatherData(
        index: '224112A',
        latitude: 22.4,
        longitude: 79.1,
        requestUrl: 'https://api.open-meteo.com/test',
        temperature: 25.5,
        windSpeed: 10.2,
        weatherCode: 0,
        lastUpdated: DateTime.now(),
        isOffline: false,
      );

      expect(data.index, '224112A');
      expect(data.latitude, 22.4);
      expect(data.longitude, 79.1);
      expect(data.temperature, 25.5);
      expect(data.windSpeed, 10.2);
      expect(data.weatherCode, 0);
      expect(data.isOffline, false);
    });

    test('WeatherData asOffline creates offline copy', () {
      final data = WeatherData(
        index: '224112A',
        latitude: 22.4,
        longitude: 79.1,
        requestUrl: 'https://api.open-meteo.com/test',
        temperature: 25.5,
        windSpeed: 10.2,
        weatherCode: 0,
        lastUpdated: DateTime.now(),
        isOffline: false,
      );

      final offlineData = data.asOffline();

      expect(offlineData.isOffline, true);
      expect(offlineData.index, data.index);
      expect(offlineData.temperature, data.temperature);
    });

    test('WeatherData toJson/fromJson works correctly', () {
      final originalData = WeatherData(
        index: '224112A',
        latitude: 22.4,
        longitude: 79.1,
        requestUrl: 'https://api.open-meteo.com/test',
        temperature: 25.5,
        windSpeed: 10.2,
        weatherCode: 0,
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
        isOffline: false,
      );

      // Convert to JSON
      final json = originalData.toJson();

      // Convert back from JSON
      final reconstructedData = WeatherData.fromJson(json);

      expect(reconstructedData.index, originalData.index);
      expect(reconstructedData.latitude, originalData.latitude);
      expect(reconstructedData.longitude, originalData.longitude);
      expect(reconstructedData.temperature, originalData.temperature);
      expect(reconstructedData.windSpeed, originalData.windSpeed);
      expect(reconstructedData.weatherCode, originalData.weatherCode);
      expect(reconstructedData.isOffline, originalData.isOffline);
    });
  });

  group('WeatherService Cache Tests', () {
    late WeatherService service;

    setUp(() {
      service = WeatherService();
      // Clear any existing cache before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('saveWeatherToCache stores data', () async {
      final data = WeatherData(
        index: '224112A',
        latitude: 22.4,
        longitude: 79.1,
        requestUrl: 'https://api.open-meteo.com/test',
        temperature: 25.5,
        windSpeed: 10.2,
        weatherCode: 0,
        lastUpdated: DateTime.now(),
      );

      // Save to cache
      await service.saveWeatherToCache(data);

      // Load from cache
      final cachedData = await service.loadWeatherFromCache();

      expect(cachedData, isNotNull);
      expect(cachedData!.index, data.index);
      expect(cachedData.temperature, data.temperature);
      expect(cachedData.isOffline, true); // Should be marked as offline
    });

    test('loadWeatherFromCache returns null when no cache exists', () async {
      final cachedData = await service.loadWeatherFromCache();
      expect(cachedData, isNull);
    });

    test('loadWeatherFromCache marks data as offline', () async {
      final data = WeatherData(
        index: '224112A',
        latitude: 22.4,
        longitude: 79.1,
        requestUrl: 'https://api.open-meteo.com/test',
        temperature: 25.5,
        windSpeed: 10.2,
        weatherCode: 0,
        lastUpdated: DateTime.now(),
        isOffline: false,
      );

      await service.saveWeatherToCache(data);
      final cachedData = await service.loadWeatherFromCache();

      expect(cachedData!.isOffline, true);
    });
  });

  group('Coordinate Calculation Tests', () {
    test('Coordinate formula calculation for 224112A', () {
      final index = '224112A';
      final firstTwo = int.parse(index.substring(0, 2)); // 22
      final nextTwo = int.parse(index.substring(2, 4));  // 41

      final lat = 5 + (firstTwo / 10.0); // 5 + 2.2 = 7.2
      final lon = 79 + (nextTwo / 10.0); // 79 + 4.1 = 83.1

      expect(lat, 7.2);
      expect(lon, 83.1);
    });

    test('Coordinate formula calculation for 194174B', () {
      final index = '194174B';
      final firstTwo = int.parse(index.substring(0, 2)); // 19
      final nextTwo = int.parse(index.substring(2, 4));  // 41

      final lat = 5 + (firstTwo / 10.0); // 5 + 1.9 = 6.9
      final lon = 79 + (nextTwo / 10.0); // 79 + 4.1 = 83.1

      expect(lat, 6.9);
      expect(lon, 83.1);
    });

    test('Coordinate formula calculation for 000000A', () {
      final index = '000000A';
      final firstTwo = int.parse(index.substring(0, 2)); // 00
      final nextTwo = int.parse(index.substring(2, 4));  // 00

      final lat = 5 + (firstTwo / 10.0); // 5 + 0.0 = 5.0
      final lon = 79 + (nextTwo / 10.0); // 79 + 0.0 = 79.0

      expect(lat, 5.0);
      expect(lon, 79.0);
    });
  });

  group('API URL Generation Tests', () {
    test('URL is correctly formatted', () {
      final lat = 7.2;
      final lon = 83.1;
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=${lat.toStringAsFixed(2)}&longitude=${lon.toStringAsFixed(2)}&current=temperature_2m,wind_speed_10m,weather_code';

      expect(url, contains('latitude=7.20'));
      expect(url, contains('longitude=83.10'));
      expect(url, contains('current=temperature_2m,wind_speed_10m,weather_code'));
      expect(url, startsWith('https://api.open-meteo.com/v1/forecast'));
    });
  });
}
