import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

/// Exam recipes and question banks bundled as assets (see tools/sync_app_content.sh).
class ContentRepository {
  ContentRepository({required this.exams, required Map<String, List<Question>> questionsByScope})
    : _byScope = questionsByScope;

  final List<Exam> exams;
  final Map<String, List<Question>> _byScope;

  static const _root = 'assets/content';

  static Future<ContentRepository> load(AssetBundle bundle) async {
    final raw = jsonDecode(await bundle.loadString('$_root/exams.json')) as Map<String, dynamic>;
    final exams = [
      for (final e in raw.entries)
        if (!e.key.startsWith('_')) Exam.fromJson(e.key, e.value as Map<String, dynamic>),
    ];
    final byScope = <String, List<Question>>{};
    for (final scope in {
      for (final e in exams)
        if (!e.comingSoon) ...e.scopes,
    }) {
      try {
        final list = jsonDecode(await bundle.loadString('$_root/questions/$scope.json')) as List;
        byScope[scope] = [for (final q in list) Question.fromJson(q as Map<String, dynamic>)];
      } catch (_) {
        // No bank for this scope yet; the exam shows as unavailable.
      }
    }
    return ContentRepository(exams: exams, questionsByScope: byScope);
  }

  List<Question> questionsFor(Exam exam) => [for (final s in exam.scopes) ...?_byScope[s]];

  bool get hasSampleContent => _byScope.values.expand((qs) => qs).any((q) => q.isSample);
}
