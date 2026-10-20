import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_exam_prep/data/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  late ProgressStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await ProgressStore.open();
  });

  test('a missed question stays weak until answered correctly twice', () async {
    final q = pool.first;
    await store.record(q, false);
    expect(store.weakIds(pool), {q.id});
    await store.record(q, true);
    expect(store.weakIds(pool), {q.id});
    await store.record(q, true);
    expect(store.weakIds(pool), isEmpty);
  });

  test('readiness is the share of questions last answered correctly', () async {
    await store.record(pool[0], true);
    await store.record(pool[1], false);
    expect(store.readiness(pool), closeTo(1 / 5, 1e-9));
    expect(store.readiness(const []), 0);
  });

  test('streak counts consecutive days and survives a reload', () async {
    final today = DateTime.now();
    await store.record(pool[0], true, now: today.subtract(const Duration(days: 1)));
    await store.record(pool[0], true, now: today);
    await store.record(pool[1], true, now: today); // same day: unchanged
    expect(store.streak, 2);
    expect((await ProgressStore.open()).streak, 2);
  });

  test('a missed day resets the streak', () async {
    await store.record(pool[0], true, now: DateTime.now().subtract(const Duration(days: 3)));
    expect(store.streak, 0);
  });

  test('language is persisted', () async {
    expect(store.lang, isNull);
    await store.setLang('en');
    expect((await ProgressStore.open()).lang, 'en');
  });
}
