import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: const Color(0xFFF8FAFC),        // Clean tech white
    primary: const Color(0xFF3B82F6),           // AI blue - trustworthy
    secondary: const Color(0xFFEFF6FF),         // Light blue for message bubbles
    tertiary: const Color(0xFFFFFFFF),          // Pure white for cards
    inversePrimary: const Color(0xFF1E40AF),    // Deep blue for emphasis
  ),
);
