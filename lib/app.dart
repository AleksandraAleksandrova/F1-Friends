import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "l10n/app_localizations.dart";

import "features/auth/presentation/auth_screen.dart";
import "features/profile/providers/profile_providers.dart";

class F1FriendsApp extends ConsumerWidget {
  const F1FriendsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFD32F2F),
      brightness: Brightness.light,
    );
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: baseScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        fontFamily: "Roboto",
        dialogTheme: DialogThemeData(
          backgroundColor: baseScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: const Color(0xFFF4F5F7),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: baseScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: baseScheme.onSurface),
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineSmall: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
              titleLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
              titleMedium: const TextStyle(fontWeight: FontWeight.w700),
              titleSmall: const TextStyle(fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(color: baseScheme.onSurfaceVariant, height: 1.35),
            ),
        cardTheme: CardThemeData(
          color: baseScheme.surface,
          elevation: 0.5,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: baseScheme.outlineVariant.withValues(alpha: 0.22)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: baseScheme.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        chipTheme: baseScheme.brightness == Brightness.light
            ? ChipThemeData(
                backgroundColor: baseScheme.surfaceContainerHighest,
                selectedColor: baseScheme.secondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: baseScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const ChipThemeData(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: baseScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: baseScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: baseScheme.primary, width: 1.4),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: baseScheme.inverseSurface,
          contentTextStyle: TextStyle(color: baseScheme.onInverseSurface),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: baseScheme.surface,
          indicatorColor: baseScheme.secondaryContainer,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
