import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import '../quiz/quiz_session.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final streak = app.progress.streak;

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('appTitle')),
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
        padding: const EdgeInsets.all(16),
        children: [
          if (app.content.hasSampleContent)
            Card(
              color: scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(app.t('sampleBanner'), style: TextStyle(color: scheme.onErrorContainer)),
                  ),
                ]),
              ),
            ),
          if (streak > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                const SizedBox(width: 6),
                Text(streak == 1 ? app.t('streakOne') : app.t('streakMany').replaceAll('{n}', '$streak'), style: Theme.of(context).textTheme.titleMedium),
              ]),
            ),
          for (final exam in app.content.exams) _ExamCard(exam: exam),
          const SizedBox(height: 24),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                app.t('disclaimer'),
                key: const Key('disclaimer'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ]),
        ],
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
    final text = Theme.of(context).textTheme;
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exam.name(app.lang), style: text.titleMedium),
            const SizedBox(height: 4),
            Text(
              available ? '${pool.length} ${app.t('questions')}' : app.t('comingSoon'),
              style: text.bodySmall,
            ),
            if (available) ...[
              const SizedBox(height: 12),
              Row(children: [
                Text('${app.t('readiness')} ${(readiness * 100).round()} %', style: text.labelMedium),
                const SizedBox(width: 12),
                Expanded(child: LinearProgressIndicator(value: readiness, minHeight: 6)),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  key: Key('practice-${exam.id}'),
                  onPressed: () => start(QuizMode.practice),
                  icon: const Icon(Icons.school_outlined),
                  label: Text(app.t('practice')),
                ),
                OutlinedButton.icon(
                  key: Key('exam-${exam.id}'),
                  onPressed: () => start(QuizMode.exam),
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(app.t('examSim')),
                ),
                if (weak.isNotEmpty)
                  OutlinedButton.icon(
                    key: Key('review-${exam.id}'),
                    onPressed: () => start(QuizMode.review),
                    icon: const Icon(Icons.replay),
                    label: Text('${app.t('review')} (${weak.length})'),
                  ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
