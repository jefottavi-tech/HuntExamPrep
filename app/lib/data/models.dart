class QuestionText {
  const QuestionText({required this.q, required this.choices, required this.explanation});

  final String q;
  final List<String> choices;
  final String explanation;

  factory QuestionText.fromJson(Map<String, dynamic> json) => QuestionText(
        q: json['q'] as String,
        choices: List<String>.from(json['choices'] as List),
        explanation: json['explanation'] as String,
      );
}

class Question {
  const Question({
    required this.id,
    required this.scope,
    required this.chapter,
    required this.texts,
    required this.answerIndex,
    required this.sourceRef,
    this.reviewYear,
    this.sourceUrl,
  });

  final String id;
  final String scope;
  final String chapter;
  final Map<String, QuestionText> texts;
  final int answerIndex;
  final String sourceRef;
  final int? reviewYear;

  /// Official page confirming the current rule (law, quebec.ca, rcmp.ca), if checked.
  final String? sourceUrl;

  /// Sample questions are placeholders until reviewed questions are bundled.
  bool get isSample => id.startsWith('sample-');

  QuestionText text(String lang) => texts[lang] ?? texts['fr']!;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        scope: json['scope'] as String,
        chapter: json['chapter'] as String,
        texts: {
          for (final lang in const ['fr', 'en'])
            if (json[lang] != null) lang: QuestionText.fromJson(json[lang] as Map<String, dynamic>),
        },
        answerIndex: json['answerIndex'] as int,
        sourceRef: json['sourceRef'] as String? ?? '',
        reviewYear: json['reviewYear'] as int?,
        sourceUrl: json['sourceUrl'] as String?,
      );
}

class Exam {
  const Exam({
    required this.id,
    required this.names,
    required this.scopes,
    this.questionCount = 50,
    this.minutes = 60,
    this.passMark = 0.8,
    this.comingSoon = false,
  });

  final String id;
  final Map<String, String> names;
  final List<String> scopes;
  final int questionCount;
  final int minutes;
  final double passMark;
  final bool comingSoon;

  String name(String lang) => names[lang] ?? names['fr'] ?? id;

  factory Exam.fromJson(String id, Map<String, dynamic> json) => Exam(
        id: id,
        names: Map<String, String>.from(json['name'] as Map),
        scopes: List<String>.from(json['scopes'] as List),
        questionCount: json['questionCount'] as int? ?? 50,
        minutes: json['minutes'] as int? ?? 60,
        passMark: (json['passMark'] as num? ?? 0.8).toDouble(),
        comingSoon: json['comingSoon'] as bool? ?? false,
      );
}
