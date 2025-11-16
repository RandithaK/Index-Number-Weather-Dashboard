import 'package:flutter/material.dart';
import 'package:weather_dashboard/theme/app_theme.dart';
import 'package:weather_dashboard/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:weather_dashboard/services/weather_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

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
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: WeatherPage(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const WeatherPage({super.key, required this.onToggleTheme});

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
                        color: theme.textTheme.bodySmall?.color?.withOpacityF(0.6)),
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
              ? Colors.white.withOpacityF(0.1)
              : Colors.black.withOpacityF(0.05),
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
                  _buildInputCard(theme),
                  const SizedBox(height: 16),

                  if (_errorMessage != null)
                    _buildErrorCard(theme, _errorMessage!),
                  if (_errorMessage != null) const SizedBox(height: 16),

                  _buildCoordinatesCard(theme),
                  const SizedBox(height: 16),

                  _buildMapPlaceholder(theme),
                  const SizedBox(height: 16),

                  if (_isOffline) _buildOfflineBanner(theme),
                  if (_isOffline) const SizedBox(height: 16),

                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFF9CA3AF),
                    title: 'Student Index',
                    value: _studentIndex ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Temperature',
                    value: _temperature ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.air,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Wind Speed',
                    value: _windSpeed ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.cloud_outlined,
                    iconColor: const Color(0xFF9CA3AF),
                    title: 'Weather Code',
                    value: _weatherCode ?? '---',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    theme: theme,
                    icon: Icons.schedule,
                    iconColor: const Color(0xFF9CA3AF),
                    title: 'Last Updated',
                    value: _lastUpdated ?? '---',
                    valueSize: 13.0,
                  ),
                  const SizedBox(height: 16),

                  _buildRequestUrlCard(theme),
                  const SizedBox(height: 24),

                  _buildFooter(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
  return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Index',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodySmall?.color?.withOpacityF(0.7))),
        const SizedBox(height: 10),
        TextField(
              controller: _indexController,
              style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'e.g., 224112A',
          hintStyle: TextStyle(
            color: theme.textTheme.bodySmall?.color?.withOpacityF(0.4)),
                filled: true,
        fillColor: isDarkMode ? AppColors.darkMuted : AppColors.lightInputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _isLoading ? null : _onFetchWeatherPressed,
              style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? AppColors.darkAccent : AppColors.lightAccent,
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: isDarkMode ? Colors.black : Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text('Fetch Weather',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesCard(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
  color: isDarkMode ? AppColors.darkAccent.withOpacityF(0.1) : AppColors.lightAccentSoft,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: isDarkMode ? AppColors.darkAccent : AppColors.lightAccent),
                const SizedBox(width: 8),
                Text('Computed Coordinates',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color
                                            ?.withOpacityF(0.6))),
                        const SizedBox(height: 6),
                        Text(_latitude ?? '---',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Longitude',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color
                                                ?.withOpacityF(0.6))),
                        const SizedBox(height: 6),
                        Text(_longitude ?? '---',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color)),
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final hasCoordinates = _latitude != null && _longitude != null;
    
    String osmUrl = '';
    String staticMapUrl = '';
    
    if (hasCoordinates) {
      final lat = double.tryParse(_latitude!.replaceAll('°', '')) ?? 0.0;
      final lon = double.tryParse(_longitude!.replaceAll('°', '')) ?? 0.0;
      osmUrl = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=12/$lat/$lon';
      
      // Using tile.openstreetmap.org with a simple static view
      // Calculate tile coordinates for zoom level 12
      final zoom = 10;
      final x = ((lon + 180) / 360 * (1 << zoom)).floor();
      final y = ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2 * (1 << zoom)).floor();
      
      // Using OSM tile server for a static map view
      staticMapUrl = 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
    }
    
    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location on Map',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: hasCoordinates
                  ? () async {
                      final uri = Uri.parse(osmUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  : null,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCard : AppColors.lightScaffold,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                  ? Colors.white.withOpacityF(0.1)
                        : Colors.black.withOpacityF(0.05),
                  ),
                ),
                child: hasCoordinates
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            // Display OpenStreetMap tile
                            Center(
                              child: Image.network(
                                staticMapUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                headers: {
                                  'User-Agent': 'WeatherDashboardApp/1.0',
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                    color: isDarkMode ? AppColors.darkAccent : AppColors.lightAccent,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback: Show coordinates-based map representation
                                  return _buildMapFallback(theme);
                                },
                              ),
                            ),
                            // Location marker overlay
                            Center(
                              child: Icon(
                                Icons.location_on,
                                size: 48,
                                color: Colors.red.shade600,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black.withOpacityF(0.5),
                                  ),
                                ],
                              ),
                            ),
                            // Overlay badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacityF(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.touch_app,
                                        size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tap to Open',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 48,
              color: theme.textTheme.bodySmall?.color
                ?.withOpacityF(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text('Map will appear after fetching weather',
                                style: TextStyle(
                    color: theme.textTheme.bodySmall?.color
                      ?.withOpacityF(0.4),
                                    fontSize: 13)),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: hasCoordinates
                  ? () async {
                      final uri = Uri.parse(osmUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  : null,
              icon: Icon(Icons.open_in_new,
                  size: 14,
          color: hasCoordinates
            ? (isDarkMode ? AppColors.darkAccent : AppColors.lightAccent)
                      : theme.textTheme.bodySmall?.color?.withOpacityF(0.3)),
              label: Text('Open in OpenStreetMap',
                  style: TextStyle(
                      color: hasCoordinates
              ? (isDarkMode ? AppColors.darkAccent : AppColors.lightAccent)
                          : theme.textTheme.bodySmall?.color?.withOpacityF(0.3),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapFallback(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final lat = double.tryParse(_latitude!.replaceAll('°', '')) ?? 0.0;
    final lon = double.tryParse(_longitude!.replaceAll('°', '')) ?? 0.0;
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
  colors: isDarkMode
    ? [AppColors.darkCard, AppColors.darkMuted]
    : [AppColors.lightAccentSoft.withOpacityF(0.9), AppColors.lightAccentSoft],
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern for map-like appearance
          CustomPaint(
            size: Size(double.infinity, 200),
            painter: GridPainter(isDarkMode: isDarkMode),
          ),
          // Coordinates display
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 64,
                  color: Colors.red.shade600,
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacityF(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to view full map',
                        style: TextStyle(
                          color: Colors.white.withOpacityF(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDarkMode ? const Color(0xFF78350F) : Colors.yellow.shade50,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isDarkMode
                ? const Color(0xFFFBBF24)
                : Colors.yellow.shade600,
            width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: isDarkMode
                    ? const Color(0xFFFBBF24)
                    : Colors.yellow.shade800,
                size: 20),
            const SizedBox(width: 12),
            Text(
              'Showing cached data (offline)',
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.yellow.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String message) {
    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade600, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade800, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
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
    double valueSize = 14.0,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacityF(isDarkMode ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyLarge?.color)),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: valueSize,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestUrlCard(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 0,
  color: isDarkMode ? AppColors.darkAccent.withOpacityF(0.1) : AppColors.lightAccentSoft,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, size: 16, color: isDarkMode ? AppColors.darkAccent : AppColors.lightAccent),
                const SizedBox(width: 8),
                Text('Request URL',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _requestUrl ?? 'Press "Fetch Weather" to generate URL',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacityF(0.7),
                  fontSize: 11,
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
                color: theme.textTheme.bodySmall?.color?.withOpacityF(0.5),
                fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Done by 224112A',
            style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacityF(0.5),
                fontSize: 12),
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

// Custom painter for grid background in map fallback
class GridPainter extends CustomPainter {
  final bool isDarkMode;

  GridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
  ..color = (isDarkMode ? Colors.white : Colors.black).withOpacityF(0.1)
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}