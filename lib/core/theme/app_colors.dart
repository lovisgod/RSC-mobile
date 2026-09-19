import 'package:flutter/material.dart';

/// Active token set. Dark is the default active theme app-wide, so these
/// constants carry the DARK column of the RSC design-system token table —
/// most widgets read `AppColors.x` directly (not `Theme.of(context)`), so
/// repointing these values is what actually reskins them today.
///
/// See [AppColorsLight] for the light-column values, used only to build
/// `AppTheme.light` for a future theme toggle.
abstract final class AppColors {
  // ─── RSC brand tokens ──────────────────────────────────
  static const Color rscMain = Color(0xFF14883A);
  static const Color rscNavyDark = Color(0xFF0D5F2E);
  static const Color rscNavyLight = Color(0xFF245996);
  static const Color rscBrand = Color(0xFFFF8200);
  static const Color rscBrandLight = Color(0xFFFF9D2E);
  static const Color rscBrandStrong = Color(0xFFFF8200);

  // ─── RSC neutral/system tokens ─────────────────────────
  static const Color rscInk = Color(0xFFF5F7F2);
  static const Color rscMuted = Color(0xFF9BA79F);
  static const Color rscSurface = Color(0xFF121713);
  static const Color rscPanel = Color(0xFF121713);
  static const Color rscLine = Color(0xFF3F4842);
  static const Color rscDanger = Color(0xFFF08070);
  static const Color rscSuccess = Color(0xFF50C982);
  static const Color rscFieldBg = Color(0xFFFFFFFF);
  static const Color rscFieldInk = Color(0xFF111712);

  /// App-specific override, not part of the source design-system token
  /// table — `rsc-field-bg` is specified as white in *both* light and dark
  /// columns there, but a white pill on an all-dark screen reads as a light-
  /// theme leftover. Used as the dark theme's actual `InputDecorationTheme`
  /// fill instead of [rscFieldBg]; [rscFieldBg]/[rscFieldInk] themselves are
  /// left untouched so they still faithfully represent the source spec.
  static const Color rscFieldSurfaceDark = Color(0xFF1E2620);
  static const Color rscSurfaceAccent = Color(0xFFAAE4E8);

  // ─── RSC navigation tokens ──────────────────────────────
  static const Color rscSidebarBg = Color(0xFF0F1712);
  static const Color rscSidebarInk = Color(0xFFF5F7F2);
  static const Color rscSidebarMuted = Color(0xFF9BA79F);
  /// "Mixed primary" in the source token table has no fixed hex — approximated
  /// as brand color at low opacity over the sidebar background.
  static const Color rscSidebarActiveBg = Color(0x29FF8200);
  static const Color rscBottomNavBg = Color(0xFF0F1712);
  static const Color rscBottomNavMuted = Color(0xFF9BA79F);

  // ─── Brand (legacy names, aliased to RSC tokens) ───────
  /// "Food" text, "Register", "Order Now", star, promo banner, avatar bg
  static const Color primary = rscBrand;
  static const Color primaryLight = rscBrandLight;
  static const Color primaryDark = rscBrandStrong;

  /// Login button, "Set Default" button, outlet card bg, nav active bg
  static const Color navy = rscMain;
  static const Color navyLight = rscNavyLight;
  static const Color navyDark = rscNavyDark;

  // ─── Backgrounds ─────────────────────────────────────
  /// Main app scaffold background
  static const Color background = rscSurface;

  /// Card / surface (login screen, address card, outlet info section)
  static const Color surface = rscPanel;

  /// Profile header & home app bar dark background
  static const Color surfaceDark = rscSidebarBg;

  // ─── Outlet card accent backgrounds ──────────────────
  /// Cactus outlet card background (dark navy-blue gradient base)
  static const Color outletCardNavy = Color(0xFF1E3160);

  /// Salmas outlet card background (forest green)
  static const Color outletCardGreen = Color(0xFF2E6B45);

  // ─── Text ─────────────────────────────────────────────
  /// Primary text — headings, outlet name, user name
  static const Color textPrimary = rscInk;

  /// Secondary text — cuisine tags, email, phone, subtitle
  static const Color textSecondary = rscMuted;

  /// Hint text — input placeholders, "You haven't placed any orders yet"
  static const Color textHint = Color(0xFF71807A);

  /// White text — used on dark/colored surfaces and buttons
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Label text — "EMAIL OR PHONE", "PASSWORD", "DEFAULT DELIVERY ADDRESS"
  static const Color textLabel = rscInk;

  // ─── Bottom nav ───────────────────────────────────────
  /// Active nav tab background
  static const Color navActiveBackground = rscSidebarActiveBg;

  /// Active nav label & icon color
  static const Color navActive = rscBrand;

  /// Inactive nav icon & label
  static const Color navInactive = rscBottomNavMuted;

  // ─── Semantic ─────────────────────────────────────────
  static const Color error = rscDanger;
  static const Color success = rscSuccess;
  static const Color warning = Color(0xFFFB8C00);

  /// Pale orange badge background — e.g. the PENDING_PAYMENT status pill.
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);

  /// Neutral badge background — e.g. a PENDING sub-order status chip.
  static const Color neutralGray = Color(0xFF9CA3AF);

  /// Pale-blue highlight tint — unread notification tile, info banner card.
  /// A low-opacity wash of [navyLight] rather than a flat light-theme hex so
  /// it still reads as a subtle highlight over the dark [surface]/[background].
  static const Color infoBackground = Color(0x33245996);

  // ─── UI ───────────────────────────────────────────────
  /// Input field border
  static const Color inputBorder = rscLine;

  /// Input field border focused
  static const Color inputBorderFocused = rscBrand;

  static const Color divider = rscLine;
  static const Color shimmer = rscLine;

  // ─── Rating ───────────────────────────────────────────
  static const Color starRating = rscBrand;
}

/// Light column of the RSC design-system token table — used only to build
/// [AppTheme.light]. Not consumed by widgets directly (widgets read the
/// dark-active [AppColors] today).
abstract final class AppColorsLight {
  static const Color rscMain = Color(0xFF0B4F2D);
  static const Color rscNavyDark = Color(0xFF06391F);
  static const Color rscNavyLight = Color(0xFF245996);
  static const Color rscBrand = Color(0xFF14883A);
  static const Color rscBrandLight = Color(0xFF2AA856);
  static const Color rscBrandStrong = Color(0xFF0F6D30);

  static const Color rscInk = Color(0xFF171B17);
  static const Color rscMuted = Color(0xFF6D7B70);
  static const Color rscSurface = Color(0xFFF8FAF8);
  static const Color rscPanel = Color(0xFFFFFFFF);
  static const Color rscLine = Color(0xFFDCE6DF);
  static const Color rscDanger = Color(0xFFA33A2B);
  static const Color rscSuccess = Color(0xFF168A4A);
  static const Color rscFieldBg = Color(0xFFFFFFFF);
  static const Color rscFieldInk = Color(0xFF111712);

  static const Color rscSidebarBg = rscMain;
  static const Color rscSidebarInk = Color(0xFFFFFFFF);
  static const Color rscSidebarMuted = Color(0x94FFFFFF);
  static const Color rscSidebarActiveBg = Color(0x29FFFFFF);
  static const Color rscBottomNavBg = Color(0xFFF8FAF8);
  static const Color rscBottomNavMuted = Color(0xFF6D7B70);
}
