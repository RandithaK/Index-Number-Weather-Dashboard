import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_dashboard/services/weather_service.dart';
import 'package:weather_dashboard/widgets/input_card.dart';
import 'package:weather_dashboard/widgets/coordinates_card.dart';
import 'package:weather_dashboard/widgets/map_card.dart';
import 'package:weather_dashboard/widgets/offline_banner.dart';
import 'package:weather_dashboard/widgets/error_card.dart';
import 'package:weather_dashboard/widgets/info_card.dart';
import 'package:weather_dashboard/widgets/request_url_card.dart';
import 'package:weather_dashboard/widgets/footer.dart';

class WeatherPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const WeatherPage({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _indexController =
      TextEditingController(text: '224112A');
  final WeatherService _weatherService = WeatherService();

  String? _studentIndex;
  String? _latitude;
  String? _longitude;
  String? _temperature;
  String? _windSpeed;
  String? _weatherCode;
  String? _lastUpdated;
  String? _requestUrl;

  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weather Lookup',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
                Text(
                  'Enter your student index to get weather data',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      size: 20,
                    ),
                  ),
                  onPressed: widget.onToggleTheme,
                  tooltip: 'Toggle Theme',
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  InputCard(
                    controller: _indexController,
                    isLoading: _isLoading,
                    onFetchPressed: _onFetchWeatherPressed,
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null)
                    ErrorCard(message: _errorMessage!),
                  if (_errorMessage != null) const SizedBox(height: 16),

                  CoordinatesCard(
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                  const SizedBox(height: 16),

                  MapCard(
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                  const SizedBox(height: 16),

                  if (_isOffline) const OfflineBanner(),
                  if (_isOffline) const SizedBox(height: 16),

                  InfoCard(
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFF9CA3AF),
                    title: 'Student Index',
                    value: _studentIndex ?? '---',
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Temperature',
                    value: _temperature ?? '---',
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.air,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Wind Speed',
                    value: _windSpeed ?? '---',
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.cloud_outlined,
                    iconColor: const Color(0xFF9CA3AF),
                    title: 'Weather Code',
                    value: _weatherCode ?? '---',
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    icon: Icons.schedule,
                    iconColor: const Color(0xFF9CA3AF),
                    title: 'Last Updated',
                    value: _lastUpdated ?? '---',
                    valueSize: 13.0,
                  ),
                  const SizedBox(height: 16),

                  RequestUrlCard(requestUrl: _requestUrl),
                  const SizedBox(height: 24),

                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onFetchWeatherPressed() async {
    final String index = _indexController.text;
    if (index.length < 4) {
      setState(() {
        _errorMessage = 'Invalid Index: Must be at least 4 characters.';
        _latitude = null;
        _longitude = null;
        _requestUrl = null;
        _studentIndex = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isOffline = false;
    });

    try {
      final int firstTwo = int.parse(index.substring(0, 2));
      final int nextTwo = int.parse(index.substring(2, 4));
      final double lat = 5 + (firstTwo / 10.0);
      final double lon = 79 + (nextTwo / 10.0);
      final String url =
          'https://api.open-meteo.com/v1/forecast?latitude=${lat.toStringAsFixed(2)}&longitude=${lon.toStringAsFixed(2)}&current=temperature_2m,wind_speed_10m,weather_code';

      final WeatherData data = await _weatherService.fetchWeather(
        index: index,
        lat: lat,
        lon: lon,
        url: url,
      );

      final String formattedTime =
          DateFormat('M/d/yyyy, h:mm:ss a').format(data.lastUpdated);

      setState(() {
        _studentIndex = data.index;
        _latitude = '${data.latitude.toStringAsFixed(2)}°';
        _longitude = '${data.longitude.toStringAsFixed(2)}°';
        _requestUrl = data.requestUrl;
        _temperature = '${data.temperature.toStringAsFixed(1)}°C';
        _windSpeed = '${data.windSpeed.toStringAsFixed(1)} km/h';
        _weatherCode = data.weatherCode.toString();
        _lastUpdated = formattedTime;
        _isOffline = false;
      });
    } catch (e) {
      final String message = e.toString().replaceFirst("Exception: ", "");

      final WeatherData? cached = await _weatherService.loadWeatherFromCache();
      if (cached != null) {
        final String formattedTime =
            DateFormat('M/d/yyyy, h:mm:ss a').format(cached.lastUpdated);
        setState(() {
          _isOffline = true;
          _studentIndex = cached.index;
          _latitude = '${cached.latitude.toStringAsFixed(2)}°';
          _longitude = '${cached.longitude.toStringAsFixed(2)}°';
          _requestUrl = cached.requestUrl;
          _temperature = '${cached.temperature.toStringAsFixed(1)}°C';
          _windSpeed = '${cached.windSpeed.toStringAsFixed(1)} km/h';
          _weatherCode = cached.weatherCode.toString();
          _lastUpdated = formattedTime;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = message;
          _temperature = '---';
          _windSpeed = '---';
          _weatherCode = '---';
          _lastUpdated = '---';
          _isOffline = false;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
