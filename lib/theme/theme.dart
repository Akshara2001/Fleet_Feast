import 'package:flutter/material.dart';
import 'colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.orange200,
    primary: AppColors.orange200,
  ),
  primaryColor: AppColors.orange200,
  scaffoldBackgroundColor: Colors.grey[100],
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 16.0),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: AppColors.grey,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(12.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: AppColors.grey,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(12.0),
    ),
    labelStyle: const TextStyle(
      fontSize: 13.0,
      color: AppColors.grey,
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.grey,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.grey,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      labelStyle: const TextStyle(
        fontSize: 13.0,
        color: AppColors.grey,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.orange200),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0)),
    textStyle:
        const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w500)),
  )),
  datePickerTheme: const DatePickerThemeData(backgroundColor: Colors.white),
);
