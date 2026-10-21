import 'package:flutter/widgets.dart';

import '../ads/ad_service.dart';
import '../data/content_repository.dart';
import '../data/progress_store.dart';
import 'strings.dart';

/// App language for a device locale: French for any French locale (fr, fr-CA, fr-FR…), English otherwise.
String langForLocale(Locale locale) => locale.languageCode == 'fr' ? 'fr' : 'en';

/// App-wide dependencies and the current language.
class AppController extends ChangeNotifier {
  AppController({required this.content, required this.progress, required this.ads, required this._lang});

  final ContentRepository content;
  final ProgressStore progress;
  final AdService ads;
  String _lang;

  String get lang => _lang;

  Future<void> setLang(String lang) async {
    _lang = lang;
    notifyListeners();
    await progress.setLang(lang);
  }

  /// Call after progress changes so screens showing stats rebuild.
  void refresh() => notifyListeners();

  String t(String key) => tr(_lang, key);
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child}) : super(notifier: controller);

  static AppController of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
