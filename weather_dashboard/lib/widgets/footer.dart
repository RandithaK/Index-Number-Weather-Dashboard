import 'package:flutter/material.dart';
import 'package:weather_dashboard/theme/colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}
