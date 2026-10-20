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
          theme: ThemeData(colorSchemeSeed: _seed, useMaterial3: true),
          darkTheme: ThemeData(colorSchemeSeed: _seed, brightness: Brightness.dark, useMaterial3: true),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
