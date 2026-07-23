import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF6366F1);      // Neon Indigo
  static const Color primaryLight = Color(0xFF818CF8); // Indigo Tint
  static const Color secondary = Color(0xFF8B5CF6);    // Electric Violet
  static const Color accent = Color(0xFFEC4899);       // Vivid Pink

  // Status Colors
  static const Color success = Color(0xFF10B981);      // Emerald Green
  static const Color warning = Color(0xFFF59E0B);      // Amber Orange
  static const Color error = Color(0xFFEF4444);        // Rose/Coral Red

  // Dark Mode Palette (Obsidian Theme)
  static const Color background = Color(0xFF0B0F19);   // Deep Obsidian
  static const Color surface = Color(0xFF161E31);      // Deep Slate
  static const Color surfaceLight = Color(0xFF222F4C); // Medium Slate
  static const Color border = Color(0xFF2A3B5C);       // Muted Border
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);  // Crisp Off-White
  static const Color textSecondary = Color(0xFF94A3B8); // Cool Slate Grey
  static const Color textMuted = Color(0xFF64748B);     // Dark Muted Grey

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1F6366F1), // Very translucent primary
      Color(0x0A8B5CF6), // Extremely translucent secondary
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
