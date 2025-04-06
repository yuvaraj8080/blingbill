import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // App Info
  static const String appName = 'BlingBill';

  // Theme Colors
  static const Color primaryColor = Color(0xFFB08A48);
  static const Color secondaryColor = Color(0xFF8E44AD);
  static const Color accentColor = Color(0xFF8E44AD);

  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightCardColor = Colors.white;
  static const Color lightSurfaceColor = Color(0xFFF2F3F5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color textMedium = Color(0xFF52616B);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color lightGold = Color(0xFFB08A48);

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkSurfaceColor = Color(0xFF2C2C2C);

  // Status Colors
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF3498DB);

  // Spacing
  static const double spacing_xxs = 4.0;
  static const double spacing_xs = 8.0;
  static const double spacing_s = 12.0;
  static const double spacing_m = 16.0;
  static const double spacing_l = 24.0;
  static const double spacing_xl = 32.0;
  static const double spacing_xxl = 48.0;

  // Border Radius
  static const double defaultRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double roundedRadius = 24.0;

  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // Elevation
  static const double cardElevation = 1.0;
  static const double appBarElevation = 0.0;
  static const double defaultElevation = 2.0;

  // Jewelry Categories
  static const List<String> jewelryCategories = [
    'Necklace',
    'Earrings',
    'Bracelet',
    'Ring',
    'Anklet',
    'Pendant',
    'Chain',
    'Set',
    'Other',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Bank Transfer',
    'Check',
    'Other',
  ];

  // Success Messages
  static const String productAdded = 'Product added successfully';
  static const String productUpdated = 'Product updated successfully';
  static const String productDeleted = 'Product deleted successfully';
  static const String billCreated = 'Bill created successfully';

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textDark);

  static TextStyle get subheadingStyle => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textDark);

  static TextStyle get bodyStyle => GoogleFonts.inter(fontSize: 14, color: textDark);

  // Light Theme
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: lightCardColor,
        foregroundColor: textDark,
        elevation: appBarElevation,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(color: textDark, fontSize: 20, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: textLight,
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: spacing_l, vertical: spacing_m),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: spacing_l, vertical: spacing_m),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing_m, vertical: spacing_m),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: textMedium),
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
      ),
      cardTheme: CardTheme(
        color: lightCardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1, space: spacing_l),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade400;
          }
          return primaryColor;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCardColor,
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor.withOpacity(0.5),
        disabledColor: Colors.grey.shade400,
        selectedShadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        labelStyle: GoogleFonts.inter(color: textDark),
        secondaryLabelStyle: GoogleFonts.inter(color: textDark.withOpacity(0.7)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurfaceColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: spacing_m, vertical: spacing_m),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),
        textStyle: GoogleFonts.inter(color: textDark),
      ),
    );
  }

  // Dark Theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurfaceColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: darkCardColor,
        foregroundColor: textLight,
        elevation: appBarElevation,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: textLight,
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: spacing_l, vertical: spacing_m),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: spacing_l, vertical: spacing_m),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing_m, vertical: spacing_m),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey.shade300),
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
      ),
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade800, thickness: 1, space: spacing_l),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade700;
          }
          return primaryColor;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCardColor,
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor.withOpacity(0.5),
        disabledColor: Colors.grey.shade700,
        selectedShadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        labelStyle: GoogleFonts.inter(color: textLight),
        secondaryLabelStyle: GoogleFonts.inter(color: textLight.withOpacity(0.7)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurfaceColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: spacing_m, vertical: spacing_m),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),
        textStyle: GoogleFonts.inter(color: textLight),
      ),
    );
  }
}
