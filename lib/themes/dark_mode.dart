import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: const Color(0xFF0F172A),        // Deep tech dark
    primary: const Color(0xFF60A5FA),           // Bright blue for dark mode
    secondary: const Color(0xFF1E293B),         // Dark message background
    tertiary: const Color.fromARGB(255, 23, 42, 63),          // Better gray for chat bubbles
    inversePrimary: const Color(0xFF93C5FD),    // Light blue accents
  ),
);



// tertiary: const Color.fromARGB(255, 195, 219, 247),   


// primary: const Color(0xFF60A5FA),  