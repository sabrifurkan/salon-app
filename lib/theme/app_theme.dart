import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Midnight Rose Palette ───
  // === LIGHT ===
  static const Color _primaryLight = Color(0xFF2B5FC2);   // royal blue
  static const Color _secondaryLight = Color(0xFF5A85DB); // light accent blue
  static const Color _surfaceLight = Color(0xFFF4F6FC);   // soft blue-white
  static const Color _backgroundLight = Color(0xFFEEF2FA);
  static const Color _cardLight = Color(0xFFFFFFFF);

  // === DARK ===
  static const Color _primaryDark = Color(0xFF7AAEE8);    // soft sky blue
  static const Color _secondaryDark = Color(0xFF5A85DB);  // accent blue
  static const Color _surfaceDark = Color(0xFF0D1425);    // deep navy
  static const Color _backgroundDark = Color(0xFF080F1C);
  static const Color _cardDark = Color(0xFF131F35);       // dark slate blue

  static const Color _errorColor = Color(0xFFD62828);
  static const Color _successColor = Color(0xFF43A047);
  static const Color _warningColor = Color(0xFFF4A261);

  // ─── Appointment colors (for calendar) ───
  static const List<Color> appointmentColors = [
    Color(0xFF7AAEE8), // sky blue
    Color(0xFF4ECDC4), // teal
    Color(0xFF6B9FE4), // cornflower blue
    Color(0xFF5A85DB), // light accent blue
    Color(0xFF9B72CF), // lavender
    Color(0xFF20B2AA), // light sea green
    Color(0xFFF4A261), // sandy brown (sıcak bir kontrast)
    Color(0xFFADD8E6), // light blue
    Color(0xFF5F9EA0), // cadet blue
    Color(0xFF90A4AE), // slate
  ];

  static Color getAppointmentColor(int index) {
    return appointmentColors[index % appointmentColors.length];
  }

  // ─── Light Theme ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A1F3A),
      ),
      scaffoldBackgroundColor: _backgroundLight,
      cardColor: _cardLight,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        // Mavi → pembe gradient efekti için solid mavi kullanıyoruz
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: _secondaryLight,  // pembe alt çizgi
        dividerColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: _primaryLight.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _cardLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          side: const BorderSide(color: _primaryLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _secondaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey.shade600),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _secondaryLight, // FAB pembe
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: _secondaryLight.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _secondaryLight);
          }
          return IconThemeData(color: Colors.grey.shade600);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                color: _secondaryLight, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surfaceLight,
        selectedIconTheme: const IconThemeData(color: _secondaryLight),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade500),
        selectedLabelTextStyle: GoogleFonts.inter(
          color: _secondaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _secondaryLight.withOpacity(0.15),
        checkmarkColor: _secondaryLight,
        labelStyle: GoogleFonts.inter(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _primaryLight,
        headerForegroundColor: Colors.white,
        dayForegroundColor:
            const WidgetStatePropertyAll(Color(0xFF1A1F3A)),
        todayForegroundColor: const WidgetStatePropertyAll(_secondaryLight),
        dayOverlayColor:
            WidgetStatePropertyAll(_secondaryLight.withOpacity(0.1)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ─── Dark Theme ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        error: _errorColor,
        onPrimary: const Color(0xFF080F1C),
        onSecondary: const Color(0xFF080F1C),
        onSurface: const Color(0xFFDDE4F5),
      ),
      scaffoldBackgroundColor: _backgroundDark,
      cardColor: _cardDark,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: const Color(0xFFDDE4F5),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFDDE4F5),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFDDE4F5),
        unselectedLabelColor: Color(0xFF7A8BAD),
        indicatorColor: _secondaryDark, // pembe alt çizgi
        dividerColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _cardDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: const Color(0xFF080F1C),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          side: const BorderSide(color: _primaryDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2540),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3A5C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3A5C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey.shade400),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _secondaryDark, // FAB pembe
        foregroundColor: Color(0xFF080F1C),
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A3A5C),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2540),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surfaceDark,
        selectedIconTheme: const IconThemeData(color: _primaryDark),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
        selectedLabelTextStyle: GoogleFonts.inter(
          color: _primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _primaryDark.withOpacity(0.2),
        checkmarkColor: _primaryDark,
        labelStyle: GoogleFonts.inter(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _cardDark,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _primaryDark.withOpacity(0.25),
        headerForegroundColor: const Color(0xFFDDE4F5),
        dayForegroundColor:
            const WidgetStatePropertyAll(Color(0xFFDDE4F5)),
        todayForegroundColor: WidgetStatePropertyAll(_primaryDark),
        dayOverlayColor:
            WidgetStatePropertyAll(_primaryDark.withOpacity(0.15)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ─── Status colors ───
  static Color getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFF6B9FE4); // mavi (planlandı)
      case 'completed':
        return const Color(0xFF43A047); // yeşil (tamamlandı)
      case 'cancelled':
        return _errorColor;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Planlandı';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }
}
