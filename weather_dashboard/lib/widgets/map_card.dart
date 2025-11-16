import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class MapCard extends StatelessWidget {
  final String? latitude;
  final String? longitude;

  const MapCard({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final hasCoordinates = latitude != null && longitude != null;

    String osmUrl = '';
    String staticMapUrl = '';

    if (hasCoordinates) {
      final lat = double.tryParse(latitude!.replaceAll('°', '')) ?? 0.0;
      final lon = double.tryParse(longitude!.replaceAll('°', '')) ?? 0.0;
      osmUrl =
          'https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=12/$lat/$lon';

      final zoom = 10;
      final x = ((lon + 180) / 360 * (1 << zoom)).floor();
      final y = ((1 -
                  log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) /
              2 *
              (1 << zoom))
          .floor();

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
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  : null,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1F2937)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: hasCoordinates
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.network(
                                staticMapUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                headers: {
                                  'User-Agent': 'WeatherDashboardApp/1.0',
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: isDarkMode
                                          ? const Color(0xFFC4B5FD)
                                          : const Color(0xFF7C3AED),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return _MapFallback(
                                    latitude: latitude!,
                                    longitude: longitude!,
                                    isDarkMode: isDarkMode,
                                  );
                                },
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.location_on,
                                size: 48,
                                color: Colors.red.shade600,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
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
                                  ?.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text('Map will appear after fetching weather',
                                style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.4),
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
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  : null,
              icon: Icon(Icons.open_in_new,
                  size: 14,
                  color: hasCoordinates
                      ? (isDarkMode
                          ? const Color(0xFFC4B5FD)
                          : const Color(0xFF7C3AED))
                      : theme.textTheme.bodySmall?.color?.withOpacity(0.3)),
              label: Text('Open in OpenStreetMap',
                  style: TextStyle(
                      color: hasCoordinates
                          ? (isDarkMode
                              ? const Color(0xFFC4B5FD)
                              : const Color(0xFF7C3AED))
                          : theme.textTheme.bodySmall?.color?.withOpacity(0.3),
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
}

class _MapFallback extends StatelessWidget {
  final String latitude;
  final String longitude;
  final bool isDarkMode;

  const _MapFallback({
    required this.latitude,
    required this.longitude,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(latitude.replaceAll('°', '')) ?? 0.0;
    final lon = double.tryParse(longitude.replaceAll('°', '')) ?? 0.0;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1F2937), const Color(0xFF374151)]
              : [const Color(0xFFE0E7FF), const Color(0xFFC7D2FE)],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: GridPainter(isDarkMode: isDarkMode),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 64,
                  color: Colors.red.shade600,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view full map',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
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
}

class GridPainter extends CustomPainter {
  final bool isDarkMode;

  GridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

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
