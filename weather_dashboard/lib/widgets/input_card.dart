import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onFetchPressed;

  const InputCard({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onFetchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'e.g., 224112A',
                hintStyle: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.4)),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF4B5563)
                    : const Color(0xFFE5E7EB),
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
              onPressed: isLoading ? null : onFetchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? const Color(0xFFC4B5FD)
                    : const Color(0xFF7C3AED),
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: isDarkMode ? Colors.black : Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Fetch Weather',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
