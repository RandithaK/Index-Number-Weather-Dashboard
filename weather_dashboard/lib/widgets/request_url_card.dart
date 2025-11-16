import 'package:flutter/material.dart';
import 'package:weather_dashboard/theme/colors.dart';

class RequestUrlCard extends StatelessWidget {
  final String? requestUrl;

  const RequestUrlCard({super.key, this.requestUrl});

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
                Icon(
                  Icons.link,
                  size: 16,
                  color: isDarkMode ? AppColors.darkAccent : AppColors.lightAccent,
                ),
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
                requestUrl ?? 'Press "Fetch Weather" to generate URL',
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
}
