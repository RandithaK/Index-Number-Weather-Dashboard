import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.purple,
  scaffoldBackgroundColor: AppColors.lightScaffold,
  cardColor: AppColors.lightCard,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
      .copyWith(surface: AppColors.lightScaffold),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.purple,
  scaffoldBackgroundColor: AppColors.darkScaffold,
  cardColor: AppColors.darkCard,
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
      .copyWith(surface: AppColors.darkScaffold),
    );
  }
}
