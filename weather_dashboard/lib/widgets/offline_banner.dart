import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}
