import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/data/content_repository.dart';

/// Validates the bundled assets themselves, so a bad sync fails the build.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled exams and questions are well formed', () async {
    final repo = await ContentRepository.load(rootBundle);
    expect(repo.exams.map((e) => e.id), containsAll(['PAL', 'ICAF', 'CRFSC']));

    for (final exam in repo.exams.where((e) => !e.comingSoon)) {
      final qs = repo.questionsFor(exam);
      expect(qs, isNotEmpty, reason: exam.id);
      for (final q in qs) {
        for (final lang in ['fr', 'en']) {
          final t = q.texts[lang];
          expect(t, isNotNull, reason: '${q.id} $lang');
          expect(t!.choices, hasLength(4), reason: '${q.id} $lang');
          expect(t.q.trim(), isNotEmpty);
          expect(t.explanation.trim(), isNotEmpty);
        }
        expect(q.answerIndex, inInclusiveRange(0, 3), reason: q.id);
      }
      final ids = qs.map((q) => q.id).toList();
      expect(ids.toSet(), hasLength(ids.length), reason: 'duplicate ids in ${exam.id}');
    }
  });
}
