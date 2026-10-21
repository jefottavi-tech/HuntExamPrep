import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/ads/ad_service.dart';
import 'package:hunt_exam_prep/app/app_scope.dart';
import 'package:hunt_exam_prep/app/links.dart';
import 'package:hunt_exam_prep/data/content_repository.dart';
import 'package:hunt_exam_prep/data/progress_store.dart';
import 'package:hunt_exam_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

class CountingAds implements AdService {
  int shown = 0;
  @override
  Future<void> showInterstitial() async => shown++;
}

void main() {
  late AppController controller;
  late CountingAds ads;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'myExams': ['PAL']});
    ads = CountingAds();
    controller = AppController(
      content: ContentRepository(exams: [exam], questionsByScope: {'federal': pool.take(3).toList()}),
      progress: await ProgressStore.open(),
      ads: ads,
      lang: 'fr',
    );
  });

  testWidgets('report button falls back to showing the email when no mail app opens', (tester) async {
    Uri? opened;
    openUrl = (uri) async {
      opened = uri;
      return false;
    };
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await tester.tap(find.byKey(const Key('practice-PAL')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('report')));
    await tester.pumpAndSettle();
    expect(opened?.scheme, 'mailto');
    expect(opened?.path, 'contact@kallistesoft.ca');
    expect(find.textContaining('contact@kallistesoft.ca'), findsOneWidget);
  });

  testWidgets('practice: feedback after each answer, then results and weak-spot review', (tester) async {
    await tester.pumpWidget(HuntExamApp(controller: controller));
    expect(find.text('Examen PAL'), findsWidgets); // exam card + Today card
    expect(find.text('3 questions'), findsOneWidget);

    await tester.tap(find.byKey(const Key('practice-PAL')));
    await tester.pumpAndSettle();
    expect(find.text('Question 1/3'), findsOneWidget);
    expect(find.byKey(const Key('feedback')), findsNothing);

    await tester.tap(find.byKey(const Key('choice-0'))); // wrong (answer is 1)
    await tester.pumpAndSettle();
    expect(find.text('Mauvaise réponse'), findsOneWidget);
    expect(find.textContaining('Explication'), findsOneWidget);
    expect(find.textContaining('Manuel de l\'étudiant CCSMAF (GRC, 2014), p. 61'), findsOneWidget);
    await tester.tap(find.byKey(const Key('next')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(const Key('choice-1')));
      await tester.pumpAndSettle();
      expect(find.text('Bonne réponse!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('next')));
      await tester.pumpAndSettle();
    }

    expect(find.text('67 %'), findsOneWidget);
    expect(ads.shown, 1);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('review-PAL')), findsOneWidget);
    expect(find.text('Revoir mes erreurs (1)'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Préparation 67 %'), findsOneWidget);
    expect(find.text('1 jour de suite'), findsOneWidget);
  });

  testWidgets('mock exam: all correct passes', (tester) async {
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await tester.tap(find.byKey(const Key('exam-PAL')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('choice-0')));
      await tester.pump();
      expect(find.byKey(const Key('feedback')), findsNothing);
      await tester.tap(find.byKey(const Key('choice-1'))); // answers can change in exam mode
      await tester.pump();
      await tester.tap(find.byKey(const Key('next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('100 %'), findsOneWidget);
    expect(find.textContaining('Réussi'), findsOneWidget);
  });

  testWidgets('language toggle switches the whole UI to English', (tester) async {
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('PAL exam'), findsWidgets); // exam card + Today card
    expect(find.text('Practice'), findsOneWidget);
    expect(controller.progress.lang, 'en');

    await tester.tap(find.byKey(const Key('practice-PAL')));
    await tester.pumpAndSettle();
    expect(find.textContaining('(en)?'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
  });

  testWidgets('back during a test asks for confirmation', (tester) async {
    await tester.pumpWidget(HuntExamApp(controller: controller));
    await tester.tap(find.byKey(const Key('practice-PAL')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Quitter le test?'), findsOneWidget);
    await tester.tap(find.text('Quitter'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('practice-PAL')), findsOneWidget); // back on the dashboard
  });
}
