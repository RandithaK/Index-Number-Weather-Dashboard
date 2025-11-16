import 'package:flutter/material.dart';
import 'package:weather_dashboard/theme/colors.dart';

class CoordinatesCard extends StatelessWidget {
  final String? latitude;
  final String? longitude;

  const CoordinatesCard({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
    color: isDarkMode
      ? AppColors.darkAccent.withOpacityF(0.1)
      : AppColors.lightAccentSoft,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on,
          size: 18,
          color: isDarkMode
            ? AppColors.darkAccent
            : AppColors.lightAccent),
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
                        Text(latitude ?? '---',
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
                        Text(longitude ?? '---',
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
}
