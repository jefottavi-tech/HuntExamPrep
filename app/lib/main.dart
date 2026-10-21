import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ads/ad_service.dart';
import 'app/app_scope.dart';
import 'data/content_repository.dart';
import 'data/progress_store.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressStore.open();
  final controller = AppController(
    content: await ContentRepository.load(rootBundle),
    progress: progress,
    ads: const NoAdService(),
    // French unless the device is in English (Québec-first app).
    lang: progress.lang ?? (PlatformDispatcher.instance.locale.languageCode == 'en' ? 'en' : 'fr'),
  );
  runApp(HuntExamApp(controller: controller));
}

class HuntExamApp extends StatelessWidget {
  const HuntExamApp({super.key, required this.controller});

  final AppController controller;

  static const _seed = Color(0xFF2F5D3A); // forest green

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    const pill = StadiumBorder();
    const tall = Size(0, 48); // comfortable touch targets
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, scrolledUnderElevation: 0, centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: pill, minimumSize: tall),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: pill, minimumSize: tall),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: pill)),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => MaterialApp(
          title: controller.t('appTitle'),
          debugShowCheckedModeBanner: false,
          locale: Locale(controller.lang, 'CA'),
          supportedLocales: const [Locale('fr', 'CA'), Locale('en', 'CA')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
