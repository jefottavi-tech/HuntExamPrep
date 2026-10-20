import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/quiz/quiz_session.dart';

import 'helpers.dart';

void main() {
  test('exam mode takes questionCount questions from the pool', () {
    final s = QuizSession.start(exam, pool, QuizMode.exam, random: Random(1));
    expect(s.questions, hasLength(3));
    expect(s.questions.map((q) => q.id).toSet(), hasLength(3));
  });

  test('practice mode is capped by the pool size', () {
    expect(QuizSession.start(exam, pool, QuizMode.practice).questions, hasLength(5));
  });

  test('review mode only uses the given ids', () {
    final s = QuizSession.start(exam, pool, QuizMode.review, onlyIds: {'q2', 'q4'});
    expect(s.questions.map((q) => q.id).toSet(), {'q2', 'q4'});
    expect(QuizSession.start(exam, pool, QuizMode.review, onlyIds: {}).isEmpty, isTrue);
  });

  test('scoring, pass mark and missed questions', () {
    final s = QuizSession.start(exam, pool, QuizMode.exam, random: Random(2));
    expect(s.answer(1), isTrue);
    s.next();
    expect(s.answer(0), isFalse);
    s.next();
    expect(s.answer(1), isTrue);
    expect(s.correctCount, 2);
    expect(s.passed, isTrue); // 2/3 >= 0.6
    expect(s.missed.single, s.questions[1]);
  });

  test('practice answers are final, exam answers can change', () {
    final practice = QuizSession.start(exam, pool, QuizMode.practice);
    practice.answer(0);
    expect(practice.answer(1), isFalse);
    expect(practice.answerAt(0), 0);

    final mock = QuizSession.start(exam, pool, QuizMode.exam);
    mock.answer(0);
    expect(mock.answer(1), isTrue);
    expect(mock.answerAt(0), 1);
  });

  test('unanswered questions count as missed', () {
    final s = QuizSession.start(exam, pool, QuizMode.exam);
    expect(s.missed, hasLength(3));
    expect(s.passed, isFalse);
  });
}
