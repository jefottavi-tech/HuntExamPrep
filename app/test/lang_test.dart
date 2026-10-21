import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/app/app_scope.dart';

void main() {
  test('French for any French device locale, English for everything else', () {
    expect(langForLocale(const Locale('fr')), 'fr');
    expect(langForLocale(const Locale('fr', 'CA')), 'fr');
    expect(langForLocale(const Locale('fr', 'FR')), 'fr');
    expect(langForLocale(const Locale('en', 'CA')), 'en');
    expect(langForLocale(const Locale('es', 'MX')), 'en');
    expect(langForLocale(const Locale('de')), 'en');
  });
}
