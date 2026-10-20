import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Local progress: last result per question, weak spots, daily streak, language.
class ProgressStore {
  ProgressStore(this._prefs)
      : _last = _readMap(_prefs, _kLast).cast<String, bool>(),
        _weak = _readMap(_prefs, _kWeak).cast<String, int>();

  final SharedPreferences _prefs;
  final Map<String, bool> _last;
  final Map<String, int> _weak;

  static const _kLast = 'lastResult';
  static const _kWeak = 'weak';
  static const _kStreak = 'streak';
  static const _kStreakDay = 'streakDay';
  static const _kLang = 'lang';

  /// A missed question leaves the weak list after this many correct answers in a row.
  static const correctToClear = 2;

  static Future<ProgressStore> open() async => ProgressStore(await SharedPreferences.getInstance());

  static Map<String, dynamic> _readMap(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  String? get lang => _prefs.getString(_kLang);
  Future<void> setLang(String lang) => _prefs.setString(_kLang, lang);

  Future<void> record(Question q, bool correct, {DateTime? now}) async {
    _last[q.id] = correct;
    if (!correct) {
      _weak[q.id] = correctToClear;
    } else if (_weak.containsKey(q.id)) {
      final left = _weak[q.id]! - 1;
      left <= 0 ? _weak.remove(q.id) : _weak[q.id] = left;
    }
    await _prefs.setString(_kLast, jsonEncode(_last));
    await _prefs.setString(_kWeak, jsonEncode(_weak));
    await _touchStreak(now ?? DateTime.now());
  }

  Set<String> weakIds(Iterable<Question> pool) => {for (final q in pool) if (_weak.containsKey(q.id)) q.id};

  /// Share of the pool whose last answer was correct (0..1).
  double readiness(List<Question> pool) =>
      pool.isEmpty ? 0 : pool.where((q) => _last[q.id] == true).length / pool.length;

  int get streak {
    final day = _prefs.getString(_kStreakDay);
    if (day == null) return 0;
    final gap = _dayNumber(DateTime.now()) - int.parse(day);
    return gap <= 1 ? _prefs.getInt(_kStreak) ?? 0 : 0;
  }

  Future<void> _touchStreak(DateTime now) async {
    final today = _dayNumber(now);
    final last = int.tryParse(_prefs.getString(_kStreakDay) ?? '');
    if (last == today) return;
    final streak = last == today - 1 ? (_prefs.getInt(_kStreak) ?? 0) + 1 : 1;
    await _prefs.setInt(_kStreak, streak);
    await _prefs.setString(_kStreakDay, '$today');
  }

  static int _dayNumber(DateTime t) => DateTime.utc(t.year, t.month, t.day).millisecondsSinceEpoch ~/ 86400000;
}
