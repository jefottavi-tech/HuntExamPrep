import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/ads/ad_service.dart';
import 'package:hunt_exam_prep/app/app_scope.dart';
import 'package:hunt_exam_prep/data/content_repository.dart';
import 'package:hunt_exam_prep/data/models.dart';
import 'package:hunt_exam_prep/data/progress_store.dart';
import 'package:hunt_exam_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class _NoAds implements AdService {
  @override
  Future<void> showInterstitial() async {}
}

void main() {
  test('photo fields parse', () {
    expect(idQuestion.image, 'assets/wildlife/moose.jpg');
    expect(idQuestion.imageCredit?.license, 'CC BY 2.0');
    expect(idQuestion.text('fr').habitat, startsWith('Forêt boréale'));
    expect(idQuestion.text('en').confuse, isNull);
  });

  testWidgets('photo question shows the photo and credit, then how to recognise it and where it lives', (tester) async {
    tester.view.physicalSize = const Size(1080, 3200); // tall phone: photo + choices + feedback on screen
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'myExams': ['ID'],
    });
    final controller = AppController(
      content: ContentRepository(
        exams: [idExam],
        questionsByScope: {
          'wildlife-id': [idQuestion],
        },
      ),
      progress: await ProgressStore.open(),
      ads: _NoAds(),
      lang: 'fr',
    );
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await openHub(tester, 'hub-recognise');
    await tester.tap(find.byKey(const Key('practice-ID')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('question-photo')), findsOneWidget);
    expect(find.textContaining('Jane Doe, CC BY 2.0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('choice-0'))); // wrong: elk
    await tester.pumpAndSettle();
    expect(find.text('Comment le reconnaître'), findsOneWidget);
    expect(find.text('Où il vit'), findsOneWidget);
    expect(find.text('Forêt boréale de tout le Canada.'), findsOneWidget);
    expect(find.textContaining('Ne pas confondre'), findsOneWidget);
  });

  testWidgets('photo space is reserved at its real shape before loading, with a spinner', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'myExams': ['ID'],
    });
    final json = Map<String, dynamic>.from(idQuestionJson)
      ..['image'] =
          'assets/wildlife/2065e8814ba5.jpg' // real black bear photo, 423x640
      ..['imageSize'] = [423, 640];
    final controller = AppController(
      content: ContentRepository(
        exams: [idExam],
        questionsByScope: {
          'wildlife-id': [Question.fromJson(json)],
        },
      ),
      progress: await ProgressStore.open(),
      ads: _NoAds(),
      lang: 'fr',
    );
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await openHub(tester, 'hub-recognise');
    await tester.tap(find.byKey(const Key('practice-ID')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // route transition; the asset is not decoded yet

    final box = tester.getSize(find.byKey(const Key('photo-box')).last); // the quiz's photo, above the dashboard's
    expect(box.height / box.width, closeTo(640 / 423, 0.02)); // whole portrait shape, reserved up front
    expect(
      find.descendant(of: find.byKey(const Key('photo-box')).last, matching: find.byType(CircularProgressIndicator)),
      findsOneWidget,
    );
  });

  testWidgets('after answering a photo question, the animal card sits right under the photo', (tester) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'myExams': ['ID'],
    });
    final controller = AppController(
      content: ContentRepository(
        exams: [idExam],
        questionsByScope: {
          'wildlife-id': [idQuestion],
        },
      ),
      progress: await ProgressStore.open(),
      ads: _NoAds(),
      lang: 'fr',
    );
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await openHub(tester, 'hub-recognise');
    await tester.tap(find.byKey(const Key('practice-ID')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('choice-1')));
    await tester.pumpAndSettle();

    final feedbackTop = tester.getTopLeft(find.byKey(const Key('feedback'))).dy;
    expect(feedbackTop, greaterThan(tester.getBottomLeft(find.byKey(const Key('photo-box'))).dy));
    expect(feedbackTop, lessThan(tester.getTopLeft(find.text('Quel est cet animal?')).dy));
  });
}
