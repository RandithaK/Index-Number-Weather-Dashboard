import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Data Model
class WeatherData {
  final String index;
  final double latitude;
  final double longitude;
  final String requestUrl;

  final double temperature;
  final double windSpeed;
  final int weatherCode;

  final DateTime lastUpdated;
  final bool isOffline;

  WeatherData({
    required this.index,
    required this.latitude,
    required this.longitude,
    required this.requestUrl,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.lastUpdated,
    this.isOffline = false,
  });

  /// Creates a new WeatherData instance with offline flag.
  WeatherData asOffline() {
    return WeatherData(
      index: index,
      latitude: latitude,
      longitude: longitude,
      requestUrl: requestUrl,
      temperature: temperature,
      windSpeed: windSpeed,
      weatherCode: weatherCode,
      lastUpdated: lastUpdated, // Keep original update time
      isOffline: true,
    );
  }

  // --- Caching Logic ---

  /// Factory constructor to parse data from cached JSON
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      index: json['index'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      requestUrl: json['requestUrl'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isOffline: json['isOffline'] as bool? ?? false,
    );
  }

  /// Converts this object to a JSON map for caching
  Map<String, dynamic> toJson() => {
        'index': index,
        'latitude': latitude,
        'longitude': longitude,
        'requestUrl': requestUrl,
        'temperature': temperature,
        'windSpeed': windSpeed,
        'weatherCode': weatherCode,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isOffline': isOffline,
      };
}

// 2. Weather Service
class WeatherService {
  final Dio _dio = Dio();
  static const String _cacheKey = 'weather_cache';

  /// Fetches weather from API and saves to cache on success.
  Future<WeatherData> fetchWeather({
    required String index,
    required double lat,
    required double lon,
    required String url,
  }) async {
    try {
      final response = await _dio.get(
        url,
        // FIX: 'timeout' is not a valid parameter. Use sendTimeout and receiveTimeout.
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        // Successful response
        final data = response.data as Map<String, dynamic>;
        
        // The API nests the data under "current_weather"
        if (data['current_weather'] == null) {
          throw Exception("Invalid API response: 'current_weather' key missing.");
        }
        
        final current = data['current_weather'] as Map<String, dynamic>;

        final weatherData = WeatherData(
          index: index,
          latitude: lat,
          longitude: lon,
          requestUrl: url,
          temperature: (current['temperature_2m'] as num).toDouble(),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
          weatherCode: (current['weather_code'] as num).toInt(),
          lastUpdated: DateTime.now(), // Set update time to now
          isOffline: false,
        );

        // Save to cache on successful fetch
        await saveWeatherToCache(weatherData);

        return weatherData;
      } else {
        // Handle non-200 status codes
        throw Exception(
            'Failed to load weather: Status Code ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (e.g., network, timeout)
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
         throw Exception('Connection timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
         throw Exception('Network error. Please check your connection.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Handle any other parsing errors
      throw Exception('An unknown error occurred: $e');
    }
  }

  // --- Caching Methods ---

  Future<void> saveWeatherToCache(WeatherData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
  }

  Future<WeatherData?> loadWeatherFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_cacheKey);
    if (dataString == null) return null;

    try {
      final json = jsonDecode(dataString) as Map<String, dynamic>;
      final cachedData = WeatherData.fromJson(json);
      return cachedData.asOffline(); // Return with offline flag
    } catch (e) {
      // Cache is corrupt, clear it
      await prefs.remove(_cacheKey);
      return null;
    }
  }
}