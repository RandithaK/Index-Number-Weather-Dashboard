import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:weather_dashboard/weather_service.dart'; // Import our new service

// --- App Entry Point ---
void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Dashboard',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Light background
        cardColor: Colors.white,
        fontFamily: 'Inter', // Assumes you've added Inter font
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
            .copyWith(background: const Color(0xFFF9FAFB)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF111827), // Dark background
        cardColor: const Color(0xFF1F2937), // Dark card
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.purple, brightness: Brightness.dark)
            .copyWith(background: const Color(0xFF111827)),
      ),
      themeMode: _themeMode,
      home: WeatherPage(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Main Weather Page UI ---
class WeatherPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const WeatherPage({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Controller for the text field
  final TextEditingController _indexController =
      TextEditingController(text: '224112A');

  // --- Weather Service ---
  final WeatherService _weatherService = WeatherService();

  // --- State Variables ---
  String? _studentIndex;
  String? _latitude;
  String? _longitude;
  String? _temperature;
  String? _windSpeed;
  String? _weatherCode;
  String? _lastUpdated;
  String? _requestUrl;

  // State for the UI
  bool _isLoading = false; // For loading indicator
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
      // Use CustomScrollView to avoid overflow and get a nice scroll
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
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                Text(
                  'Enter your student index to get weather data',
                  style: TextStyle(
                      fontSize: 14,
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded),
                onPressed: widget.onToggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          // Main content area
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  // 1. Input Card
                  _buildInputCard(theme),
                  const SizedBox(height: 16),

                  // Error Message Card (conditionally shown)
                  if (_errorMessage != null)
                    _buildErrorCard(theme, _errorMessage!),
                  if (_errorMessage != null) const SizedBox(height: 16),

                  // 2. Computed Coordinates Card
                  _buildCoordinatesCard(theme),
                  const SizedBox(height: 16),

                  // 3. Map Placeholder
                  _buildMapPlaceholder(theme),
                  const SizedBox(height: 16),

                  // 4. Offline Banner (conditionally shown)
                  if (_isOffline) _buildOfflineBanner(theme),
                  if (_isOffline) const SizedBox(height: 16),

                  // 5. Weather Results
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.person_search_rounded,
                    iconColor: Colors.grey,
                    title: 'Student Index',
                    value: _studentIndex ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.thermostat_rounded,
                    iconColor: Colors.red,
                    title: 'Temperature',
                    value: _temperature ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.wind_power_rounded,
                    iconColor: Colors.blue,
                    title: 'Wind Speed',
                    value: _windSpeed ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.cloud_rounded,
                    iconColor: Colors.grey,
                    title: 'Weather Code',
                    value: _weatherCode ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.access_time_filled_rounded,
                    iconColor: Colors.grey,
                    title: 'Last Updated',
                    value: _lastUpdated ?? '---',
                    valueSize: 14.0,
                  ),
                  const SizedBox(height: 16),

                  // 6. Request URL
                  _buildRequestUrlCard(theme),
                  const SizedBox(height: 24),

                  // Footer
                  _buildFooter(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builder Methods ---

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Index', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _indexController,
              decoration: InputDecoration(
                hintText: 'e.g., 224112A',
                filled: true,
                fillColor: theme.colorScheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _onFetchWeatherPressed, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white, // Added for better dark mode contrast
                minimumSize: const Size(double.infinity, 48), // Added minimum size
                shape: RoundedRectangleBorder( // Added shape
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Fetch Weather',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map_rounded, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text('Computed Coordinates',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('Latitude', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(_latitude ?? '---',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('Longitude', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(_longitude ?? '---',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(ThemeData theme) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location on Map',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('Map Placeholder',
                    style: TextStyle(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.5))),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement URL Launcher if you have time
              },
              icon: Icon(Icons.open_in_new_rounded,
                  size: 16, color: theme.primaryColor),
              label: Text('Open in OpenStreetMap',
                  style: TextStyle(color: theme.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(ThemeData theme) {
    return Card(
      elevation: 1,
      color: Colors.yellow.shade100,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.yellow.shade700, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.yellow.shade800),
            const SizedBox(width: 12),
            Text(
              'Showing cached data (offline)',
              style: TextStyle(
                  color: Colors.yellow.shade900, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String message) {
    return Card(
      elevation: 1,
      color: Colors.red.shade100,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade700, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    color: Colors.red.shade900, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    double valueSize = 16.0,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: valueSize,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestUrlCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link_rounded,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text('Request URL',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _requestUrl ?? 'Press "Fetch Weather" to generate URL',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Text(
            'Powered by Open-Meteo API',
            style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            // Show the index from the state, fallback to placeholder
            'Done by ${(_studentIndex ?? _indexController.text).replaceAll(RegExp(r'[^0-9]'), '')}',
            style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- Logic Methods ---

  /// This is the core logic for Milestones 3, 4, and 5.
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

    // 1. Set Loading State
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isOffline = false; // Reset offline status
    });

    try {
      // 2. Core Logic (Derive Coords)
      final int firstTwo = int.parse(index.substring(0, 2));
      final int nextTwo = int.parse(index.substring(2, 4));
      final double lat = 5 + (firstTwo / 10.0);
      final double lon = 79 + (nextTwo / 10.0);
      final String url =
          'https://api.open-meteo.com/v1/forecast?latitude=${lat.toStringAsFixed(2)}&longitude=${lon.toStringAsFixed(2)}&current_weather=true&temperature_unit=celsius&wind_speed_unit=kmh&current=temperature_2m,wind_speed_10m,weather_code';

      // 3. API Call
      final WeatherData data = await _weatherService.fetchWeather(
        index: index,
        lat: lat,
        lon: lon,
        url: url,
      );

      // 4. Success (Online) - Format and update state
      final String formattedTime =
          DateFormat('M/d/yyyy, h:mm:ss a').format(data.lastUpdated);

      setState(() {
        _studentIndex = data.index;
        _latitude = '${data.latitude.toStringAsFixed(2)}°';
        _longitude = '${data.longitude.toStringAsFixed(2)}°';
        _requestUrl = data.requestUrl;
        _temperature = '${data.temperature}°C';
        _windSpeed = '${data.windSpeed} km/h';
        _weatherCode = data.weatherCode.toString();
        _lastUpdated = formattedTime;
        _isOffline = false; // We are online
      });
    } catch (e) {
      // 5. Error (Handle Offline/Failure)
      final String message = e.toString().replaceFirst("Exception: ", "");

      // Try to load cached data
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
          _temperature = '${cached.temperature}°C';
          _windSpeed = '${cached.windSpeed} km/h';
          _weatherCode = cached.weatherCode.toString();
          _lastUpdated = formattedTime;
          _errorMessage = null; // clear API error because we are showing cached data
        });
      } else {
        // No cache available, show the network error
        setState(() {
          _errorMessage = message;
          // Clear old data for clarity
          _temperature = '---';
          _windSpeed = '---';
          _weatherCode = '---';
          _lastUpdated = '---';
          _isOffline = false;
        });
      }
    } finally {
      // 8. Clean up
      setState(() {
        _isLoading = false;
      });
    }
  }
}