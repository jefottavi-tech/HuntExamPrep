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
    SharedPreferences.setMockInitialValues({});
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

  testWidgets('portrait photos are shown whole, never cropped to a fixed frame', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final json = Map<String, dynamic>.from(idQuestionJson)
      ..['image'] = 'assets/wildlife/2065e8814ba5.jpg'; // black bear, 423x640
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
    await tester.tap(find.byKey(const Key('practice-ID')));
    await tester.pumpAndSettle();
    final element = tester.element(find.byKey(const Key('question-photo')));
    await tester.runAsync(() => precacheImage(AssetImage(json['image'] as String), element)); // decode the real asset
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byKey(const Key('question-photo')));
    expect(size.height / size.width, closeTo(640 / 423, 0.05)); // whole portrait photo, head included
  });
}
