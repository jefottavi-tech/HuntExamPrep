import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import '../quiz/quiz_session.dart';
import 'quiz_screen.dart';

/// How each exam is presented on the home screen.
typedef _ExamStyle = ({IconData icon, String region, bool firearms});

const _styles = <String, _ExamStyle>{
  'PAL': (icon: Icons.shield_outlined, region: 'Canada', firearms: true),
  'CRFSC': (icon: Icons.lock_outline, region: 'Canada', firearms: true),
  'ICAF': (icon: Icons.forest_outlined, region: 'Québec', firearms: false),
  'ABHE': (icon: Icons.landscape_outlined, region: 'Alberta', firearms: false),
};
const _fallback = (icon: Icons.school_outlined, region: '', firearms: true);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final streak = app.progress.streak;
    final exams = app.content.exams;
    final firearms = [
      for (final e in exams)
        if ((_styles[e.id] ?? _fallback).firearms) e,
    ];
    final hunting = [
      for (final e in exams)
        if (!(_styles[e.id] ?? _fallback).firearms) e,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('appTitle'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<String>(
              key: const Key('langToggle'),
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: 'fr', label: Text('FR')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {app.lang},
              onSelectionChanged: (s) => app.setLang(s.first),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (app.content.hasSampleContent) ...[
            _Banner(icon: Icons.warning_amber_rounded, text: app.t('sampleBanner')),
            const SizedBox(height: 12),
          ],
          Text(app.t('heroTitle'), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(app.t('heroSubtitle'), style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          if (streak > 0) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 18),
                label: Text(streak == 1 ? app.t('streakOne') : app.t('streakMany').replaceAll('{n}', '$streak')),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _HowItWorks(),
          for (final (title, group) in [(app.t('groupFirearms'), firearms), (app.t('groupHunting'), hunting)])
            if (group.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              for (final exam in group) ...[_ExamCard(exam: exam), const SizedBox(height: 12)],
            ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  app.t('disclaimer'),
                  key: const Key('disclaimer'),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explains the two modes once, so the buttons on each card need no guessing.
class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    Widget row(IconData icon, String mode, String how) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$mode  ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: how,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            row(Icons.school_outlined, app.t('practice'), app.t('howPractice')),
            row(Icons.timer_outlined, app.t('examSim'), app.t('howExam')),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final style = _styles[exam.id] ?? _fallback;
    final pool = app.content.questionsFor(exam);
    final available = !exam.comingSoon && pool.isNotEmpty;
    final readiness = app.progress.readiness(pool);
    final weak = app.progress.weakIds(pool);

    void start(QuizMode mode) {
      final session = QuizSession.start(exam, pool, mode, onlyIds: mode == QuizMode.review ? weak : null);
      if (session.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(app.t(mode == QuizMode.review ? 'noWeak' : 'noQuestions'))));
        return;
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QuizScreen(session: session)))
          .then((_) => app.refresh());
    }

    final meta = [
      if (style.region.isNotEmpty) style.region,
      if (available) app.t('minutes').replaceAll('{n}', '${exam.minutes}'),
      if (available) app.t('toPass').replaceAll('{p}', '${(exam.passMark * 100).round()}'),
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(style.icon, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.name(app.lang), style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        available ? '${pool.length} ${app.t('questions')}' : app.t('comingSoon'),
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (meta.isNotEmpty) Text(meta, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (available) _Readiness(value: readiness),
              ],
            ),
            if (available) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: Key('practice-${exam.id}'),
                      onPressed: () => start(QuizMode.practice),
                      icon: const Icon(Icons.school_outlined),
                      label: Text(app.t('practice')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: Key('exam-${exam.id}'),
                      onPressed: () => start(QuizMode.exam),
                      icon: const Icon(Icons.timer_outlined),
                      label: Text(app.t('examSim'), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
              if (weak.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton.icon(
                    key: Key('review-${exam.id}'),
                    onPressed: () => start(QuizMode.review),
                    icon: const Icon(Icons.replay),
                    label: Text('${app.t('reviewMistakes')} (${weak.length})'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small ring showing how ready the user is for this exam.
class _Readiness extends StatelessWidget {
  const _Readiness({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final pct = (value * 100).round();
    return Semantics(
      label: '${app.t('readiness')} $pct %',
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Text('$pct%', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(app.t('readiness'), style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
