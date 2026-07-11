import 'package:chatx_app/config/colors.dart';
import 'package:flutter/material.dart';


var lightTheme = ThemeData();
var darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: darkPrimaryColor,
    onPrimary:darkOnBackgroundColor ,
    surface: darkBackgroundColor,
    onSurface: darkOnBackgroundColor,
    primaryContainer: darkContainerColor,
    onPrimaryContainer: darkOnContainerColor,
  ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: darkContainerColor,
      foregroundColor: darkOnBackgroundColor,
    ),
    textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: darkPrimaryColor,
            fontFamily: "Poppins"
        ),
        headlineMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: darkOnBackgroundColor,
            fontFamily: "Poppins"
        ),
        headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkOnBackgroundColor,
            fontFamily: "Poppins"
        ),
        labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: darkOnContainerColor,
            fontFamily: "Poppins"
        ),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: darkOnContainerColor,
            fontFamily: "Poppins"
        ),
        labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w300,
            color: darkOnContainerColor,
            fontFamily: "Poppins"
        ),
        bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: darkOnBackgroundColor,
            fontFamily: "Poppins"
        ),
        bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: darkOnBackgroundColor,
            fontFamily: "Poppins"
        ),
    )
);
