import 'package:hunt_exam_prep/data/models.dart';

const exam = Exam(id: 'PAL', names: {'fr': 'Examen PAL', 'en': 'PAL exam'}, scopes: ['federal'], questionCount: 3, passMark: 0.6);

Question question(String id, {int answer = 1}) => Question(
      id: id,
      scope: 'federal',
      chapter: 'ch01',
      answerIndex: answer,
      sourceRef: 'cfsc_fr.pdf p.61',
      texts: {
        'fr': QuestionText(q: 'Question $id?', choices: const ['Un', 'Deux', 'Trois', 'Quatre'], explanation: 'Explication $id.'),
        'en': QuestionText(q: 'Question $id (en)?', choices: const ['One', 'Two', 'Three', 'Four'], explanation: 'Explanation $id.'),
      },
    );

final pool = [for (var i = 1; i <= 5; i++) question('q$i')];
