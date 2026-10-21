import 'dart:math';

import '../data/models.dart';

enum QuizMode { practice, exam, review }

/// One run through a set of questions. Pure Dart, no UI.
class QuizSession {
  QuizSession._(this.exam, this.mode, this.questions);

  final Exam exam;
  final QuizMode mode;
  final List<Question> questions;
  final Map<int, int> _answers = {};
  int current = 0;

  static const practiceSize = 20;

  /// [onlyIds] restricts the pool (weak-spot review).
  factory QuizSession.start(
    Exam exam,
    List<Question> pool,
    QuizMode mode, {
    Random? random,
    Set<String>? onlyIds,
  }) {
    final candidates = [
      for (final q in pool)
        if (onlyIds == null || onlyIds.contains(q.id)) q,
    ]..shuffle(random ?? Random());
    final size = switch (mode) {
      QuizMode.exam => exam.questionCount,
      QuizMode.practice || QuizMode.review => practiceSize,
    };
    return QuizSession._(exam, mode, candidates.take(size).toList());
  }

  bool get isEmpty => questions.isEmpty;
  Question get question => questions[current];
  bool get isLast => current == questions.length - 1;
  int? answerAt(int index) => _answers[index];
  bool get currentAnswered => _answers.containsKey(current);

  /// Records the answer to the current question; returns whether it was correct.
  /// In practice/review the first answer is final; in exam mode it can be changed.
  bool answer(int choice) {
    if (mode != QuizMode.exam && currentAnswered) return _answers[current] == question.answerIndex;
    _answers[current] = choice;
    return choice == question.answerIndex;
  }

  void next() {
    if (!isLast) current++;
  }

  int get correctCount =>
      [for (var i = 0; i < questions.length; i++) _answers[i] == questions[i].answerIndex].where((c) => c).length;

  double get score => questions.isEmpty ? 0 : correctCount / questions.length;
  bool get passed => score >= exam.passMark;

  List<Question> get missed => [for (final (q, _) in missedWithAnswers) q];

  /// Missed questions with the choice the user picked (null if left unanswered).
  List<(Question, int?)> get missedWithAnswers => [
        for (var i = 0; i < questions.length; i++)
          if (_answers[i] != questions[i].answerIndex) (questions[i], _answers[i]),
      ];
}
