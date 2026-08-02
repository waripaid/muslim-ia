import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const primary = Color(0xFFC5A028);
  static const primaryDark = Color(0xFF9B7B1C);
  static const primaryLight = Color(0xFFE8C547);
  static const primarySurface = Color(0xFFFFF8E1);
  static const accent = Color(0xFFD4AF37);
  static const accentLight = Color(0xFFF5E6B8);
  static const background = Color(0xFFFAF8F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1A1A1A);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const success = Color(0xFF059669);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const cardBorder = Color(0xFFEBE5D7);
  static const shimmer = Color(0xFFFEF3C7);

  /// Adaptatif : utilise la couleur sombre si le thème est dark
  static Color surfaceAdaptive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFFFF);

  static Color backgroundAdaptive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFFAF8F3);

  static Color cardBorderAdaptive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A3E) : const Color(0xFFEBE5D7);

  static Color primarySurfaceAdaptive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF252540) : const Color(0xFFFFF8E1);

  static Color textOnSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE2E8F0) : const Color(0xFF1A1A1A);
}

/// Dégradés partagés pour une identité visuelle cohérente
class AppGradients {
  /// Or premium (boutons principaux, éléments d'accent)
  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C547), Color(0xFFC5A028), Color(0xFF9B7B1C)],
  );

  /// Bleu nuit profond (fond des écrans d'auth)
  static const navy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E2E), Color(0xFF0F1B4C), Color(0xFF1E3A8A)],
  );

  /// Fond dégradé délicat (bannières, en-têtes doux)
  static const softGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8E1), Color(0xFFFAF8F3)],
  );

  /// Dégradé émeraude (succès, avancée)
  static const success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}

/// Transition de page premium : la nouvelle page s'élève en fondu + léger zoom,
/// la page précédente glisse doucement vers la gauche et s'atténue.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedIn = CurvedAnimation(
      parent: animation,
      curve: const Cubic(0.16, 1, 0.3, 1),
      reverseCurve: const Cubic(0.4, 0, 1, 1),
    );

    final outgoing = secondaryAnimation.drive(
      Tween(begin: const Offset(0.0, 0.0), end: const Offset(-0.14, 0.0))
          .chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    final outgoingOpacity = secondaryAnimation.drive(
      Tween(begin: 1.0, end: 0.55).chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    return SlideTransition(
      position: outgoing,
      child: FadeTransition(
        opacity: outgoingOpacity,
        child: FadeTransition(
          opacity: curvedIn,
          child: ScaleTransition(
            scale: curvedIn.drive(Tween(begin: 0.965, end: 1.0)),
            child: SlideTransition(
              position: curvedIn.drive(
                Tween(begin: const Offset(0.05, 0.045), end: Offset.zero),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme-aware colors that switch between light/dark
class ThemeColors {
  final Color surface;
  final Color background;
  final Color cardBorder;
  final Color primarySurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;

  const ThemeColors({
    required this.surface,
    required this.background,
    required this.cardBorder,
    required this.primarySurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
  });

  static ThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _dark : _light;
  }

  static const _light = ThemeColors(
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFFAF8F3),
    cardBorder: Color(0xFFEBE5D7),
    primarySurface: Color(0xFFFFF8E1),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B7280),
    textLight: Color(0xFF9CA3AF),
  );

  static const _dark = ThemeColors(
    surface: Color(0xFF1E1E2E),
    background: Color(0xFF121212),
    cardBorder: Color(0xFF2A2A3E),
    primarySurface: Color(0xFF252540),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textLight: Color(0xFF64748B),
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'System',
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.accent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.accent),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          shadowColor: const Color(0xFFC5A028).withValues(alpha: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 15),
        prefixIconColor: AppColors.textLight,
        suffixIconColor: AppColors.textLight,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x40C5A028),
        selectionHandleColor: AppColors.primary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.cardBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.cardBorder, thickness: 0.5),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : AppColors.textLight),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.primary : AppColors.cardBorder),
        trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFFF1EADB),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
    );
  }

  static ThemeData get darkTheme {
    final darkScheme = ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.primary,
      surface: const Color(0xFF1E1E2E),
      onSurface: const Color(0xFFE2E8F0),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: AppColors.accent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: AppColors.accent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent),
        iconTheme: IconThemeData(color: AppColors.accent),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E2E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A2E),
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: Color(0x40D4AF37),
        selectionHandleColor: AppColors.accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2A3E), thickness: 0.5),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFE2E8F0)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E2E),
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: Color(0xFF3A3A4E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.black : Color(0xFF94A3B8)),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.accent : Color(0xFF3A3A4E)),
        trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accent),
    );
  }
}
