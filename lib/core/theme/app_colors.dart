import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Brand ───────────────────────────────────────────
  /// "Food" text, "Register", "Order Now", star, promo banner, avatar bg
  static const Color primary = Color(0xFFD4832A);
  static const Color primaryLight = Color(0xFFE09A4A);
  static const Color primaryDark = Color(0xFFB86E1A);

  /// Login button, "Set Default" button, outlet card bg, nav active bg
  static const Color navy = Color(0xFF1E3160);
  static const Color navyLight = Color(0xFF253972);
  static const Color navyDark = Color(0xFF141F3D);

  // ─── Backgrounds ─────────────────────────────────────
  /// Main app scaffold background (light gray seen on profile & home)
  static const Color background = Color(0xFFF0F2F5);

  /// Card / surface white (login screen, address card, outlet info section)
  static const Color surface = Color(0xFFFFFFFF);

  /// Profile header & home app bar dark navy background
  static const Color surfaceDark = Color(0xFF1A2B52);

  // ─── Outlet card accent backgrounds ──────────────────
  /// Cactus outlet card background (dark navy-blue gradient base)
  static const Color outletCardNavy = Color(0xFF1E3160);

  /// Salmas outlet card background (forest green)
  static const Color outletCardGreen = Color(0xFF2E6B45);

  // ─── Text ─────────────────────────────────────────────
  /// Primary text — headings, outlet name, user name
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary text — cuisine tags, email, phone, subtitle
  static const Color textSecondary = Color(0xFF6B7280);

  /// Hint text — input placeholders, "You haven't placed any orders yet"
  static const Color textHint = Color(0xFFADB5BD);

  /// White text — used on navy/dark surfaces and buttons
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Label text — "EMAIL OR PHONE", "PASSWORD", "DEFAULT DELIVERY ADDRESS"
  static const Color textLabel = Color(0xFF1E3160);

  // ─── Bottom nav ───────────────────────────────────────
  /// Active nav tab background (warm cream/beige tint behind Home icon)
  static const Color navActiveBackground = Color(0xFFF5EFE6);

  /// Active nav label & icon color
  static const Color navActive = Color(0xFFD4832A);

  /// Inactive nav icon & label
  static const Color navInactive = Color(0xFF6B7280);

  // ─── Semantic ─────────────────────────────────────────
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);

  // ─── UI ───────────────────────────────────────────────
  /// Input field border
  static const Color inputBorder = Color(0xFFD1D5DB);

  /// Input field border focused
  static const Color inputBorderFocused = Color(0xFF1E3160);

  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmer = Color(0xFFE0E0E0);

  // ─── Rating ───────────────────────────────────────────
  static const Color starRating = Color(0xFFD4832A);
}