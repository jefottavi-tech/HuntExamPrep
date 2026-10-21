import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/ads/ad_service.dart';
import 'package:hunt_exam_prep/app/app_scope.dart';
import 'package:hunt_exam_prep/data/content_repository.dart';
import 'package:hunt_exam_prep/data/models.dart';
import 'package:hunt_exam_prep/data/progress_store.dart';
import 'package:hunt_exam_prep/main.dart';
import 'package:hunt_exam_prep/screens/photo_of_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class _NoAds implements AdService {
  @override
  Future<void> showInterstitial() async {}
}

const icaf = Exam(id: 'ICAF', names: {'fr': 'Examen ICAF', 'en': 'ICAF exam'}, scopes: ['federal'], questionCount: 3);

Future<AppController> _app(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppController(
    content: ContentRepository(
      exams: [exam, icaf, idExam],
      questionsByScope: {
        'federal': pool,
        'wildlife-id': [idQuestion],
      },
    ),
    progress: await ProgressStore.open(),
    ads: _NoAds(),
    lang: 'fr',
  );
}

void _tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 3600);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('first launch asks for my exams; the dashboard then puts them first', (tester) async {
    _tallScreen(tester);
    final controller = await _app({});
    await tester.pumpWidget(HuntExamApp(controller: controller));
    expect(find.text('Quel examen préparez-vous?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('picker-PAL')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('picker-continue')));
    await tester.pumpAndSettle();

    expect(controller.progress.myExams, ['PAL']);
    expect(find.byKey(const Key('hub-exams')), findsOneWidget);
    expect(find.byKey(const Key('hub-recognise')), findsOneWidget);
    expect(find.byKey(const Key('today-practice')), findsOneWidget);
    expect(find.byKey(const Key('footer')), findsOneWidget); // legal line always visible

    await openHub(tester, 'hub-exams');
    expect(find.byKey(const Key('practice-PAL')), findsOneWidget); // full card under "My exams"
    expect(find.byKey(const Key('other-ICAF')), findsOneWidget); // compact row under "Other tests"
    expect(find.byKey(const Key('other-ID')), findsNothing); // recognition games live in the other hub
  });

  testWidgets('an "other test" row opens its full card in a sheet', (tester) async {
    _tallScreen(tester);
    await tester.pumpWidget(
      HuntExamApp(
        controller: await _app({
          'myExams': ['PAL'],
        }),
      ),
    );
    await openHub(tester, 'hub-exams');
    await tester.tap(find.byKey(const Key('other-ICAF')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('practice-ICAF')), findsOneWidget);
    expect(find.byKey(const Key('exam-ICAF')), findsOneWidget);
  });

  testWidgets('the recognition hub lists the photo game', (tester) async {
    _tallScreen(tester);
    await tester.pumpWidget(
      HuntExamApp(
        controller: await _app({
          'myExams': ['PAL'],
        }),
      ),
    );
    await openHub(tester, 'hub-recognise');
    expect(find.byKey(const Key('practice-ID')), findsOneWidget);
    expect(find.byKey(const Key('practice-PAL')), findsNothing);
  });

  testWidgets('photo of the day: answered inline, remembered, and counted toward the goal', (tester) async {
    _tallScreen(tester);
    final controller = await _app({
      'myExams': ['PAL'],
    });
    await tester.pumpWidget(HuntExamApp(controller: controller));
    expect(find.byKey(const Key('photo-of-day')), findsOneWidget);
    expect(find.byKey(const Key('pod-play')), findsNothing);

    await tester.tap(find.byKey(const Key('pod-choice-1'))); // right answer (moose)
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse!'), findsOneWidget);
    expect(find.byKey(const Key('pod-play')), findsOneWidget);
    expect(controller.progress.photoOfDayChoice(), 1);
    expect(controller.progress.answeredToday(), 1);
    expect(find.text('1 / 20 questions aujourd\'hui'), findsOneWidget);
  });

  test('photo of the day is the same all day and changes the next day', () {
    final photos = [idQuestion, for (final q in pool) q];
    final morning = PhotoOfDay.pick(photos, DateTime(2026, 10, 21, 7));
    expect(PhotoOfDay.pick(photos, DateTime(2026, 10, 21, 23)), morning);
    expect(PhotoOfDay.pick(photos, DateTime(2026, 10, 22, 7)), isNot(morning));
    expect(PhotoOfDay.pick(const [], DateTime(2026, 10, 21)), isNull);
  });

  test('daily count goes up with each answer and starts over the next day', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await ProgressStore.open();
    final day1 = DateTime(2026, 10, 21, 9);
    await store.record(pool[0], true, now: day1);
    await store.record(pool[1], false, now: day1);
    expect(store.answeredToday(now: day1), 2);
    final day2 = DateTime(2026, 10, 22, 9);
    expect(store.answeredToday(now: day2), 0);
    await store.record(pool[2], true, now: day2);
    expect(store.answeredToday(now: day2), 1);
  });
}
