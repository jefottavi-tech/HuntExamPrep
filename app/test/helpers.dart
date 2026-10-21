import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/data/models.dart';

const exam = Exam(
  id: 'PAL',
  names: {'fr': 'Examen PAL', 'en': 'PAL exam'},
  scopes: ['federal'],
  questionCount: 3,
  passMark: 0.6,
);

Question question(String id, {int answer = 1}) => Question(
  id: id,
  scope: 'federal',
  chapter: 'ch01',
  answerIndex: answer,
  sourceRef: 'cfsc_fr.pdf p.61',
  texts: {
    'fr': QuestionText(
      q: 'Question $id?',
      choices: const ['Un', 'Deux', 'Trois', 'Quatre'],
      explanation: 'Explication $id.',
    ),
    'en': QuestionText(
      q: 'Question $id (en)?',
      choices: const ['One', 'Two', 'Three', 'Four'],
      explanation: 'Explanation $id.',
    ),
  },
);

final pool = [for (var i = 1; i <= 5; i++) question('q$i')];

const idExam = Exam(
  id: 'ID',
  names: {'fr': "Qu'est-ce que c'est?", 'en': 'What is it?'},
  scopes: ['wildlife-id'],
  questionCount: 2,
);

/// A "What is it?" question as tools/wildlife_id.py builds it.
final idQuestionJson = <String, dynamic>{
  'id': 'id-moose',
  'scope': 'wildlife-id',
  'chapter': 'hoofed',
  'answerIndex': 1,
  'sourceRef': '',
  'sourceUrl': 'https://www.hww.ca/en/wildlife/mammals/moose.html',
  'image': 'assets/wildlife/moose.jpg',
  'imageCredit': {
    'author': 'Jane Doe',
    'license': 'CC BY 2.0',
    'page': 'https://commons.wikimedia.org/wiki/File:Moose.jpg',
  },
  'fr': {
    'q': 'Quel est cet animal?',
    'choices': ['Wapiti', 'Orignal', 'Caribou', 'Cerf mulet'],
    'explanation': 'Très grand, museau en forme de cloche.',
    'habitat': 'Forêt boréale de tout le Canada.',
    'confuse': 'Ne pas confondre avec un cheval.',
  },
  'en': {
    'q': 'What animal is this?',
    'choices': ['Elk', 'Moose', 'Caribou', 'Mule deer'],
    'explanation': 'Very large, bulbous muzzle.',
    'habitat': 'Boreal forest across Canada.',
  },
};
final idQuestion = Question.fromJson(idQuestionJson);

/// Opens a dashboard hub card: 'hub-exams' (exam training) or 'hub-recognise' (recognition games).
Future<void> openHub(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
