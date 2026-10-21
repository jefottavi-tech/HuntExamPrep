import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import '../quiz/quiz_session.dart';
import 'quiz_screen.dart';

/// Sections exams are grouped in (picker, dashboard), in display order, with their title key.
enum ExamGroup {
  firearms('groupFirearms'),
  hunting('groupHunting'),
  identification('groupId');

  const ExamGroup(this.titleKey);
  final String titleKey;
}

typedef ExamStyle = ({IconData icon, String region, ExamGroup group});

const _styles = <String, ExamStyle>{
  'PAL': (icon: Icons.shield_outlined, region: 'Canada', group: ExamGroup.firearms),
  'CRFSC': (icon: Icons.lock_outline, region: 'Canada', group: ExamGroup.firearms),
  'ICAF': (icon: Icons.forest_outlined, region: 'Québec', group: ExamGroup.hunting),
  'ABHE': (icon: Icons.landscape_outlined, region: 'Alberta', group: ExamGroup.hunting),
  'ID': (icon: Icons.photo_camera_outlined, region: 'Canada', group: ExamGroup.identification),
};
const _fallback = (icon: Icons.school_outlined, region: '', group: ExamGroup.firearms);

ExamStyle examStyle(String examId) => _styles[examId] ?? _fallback;

/// Starts a quiz on [exam]; review mode only uses the user's weak questions.
void startQuiz(BuildContext context, Exam exam, QuizMode mode) {
  final app = AppScope.of(context);
  final pool = app.content.questionsFor(exam);
  final weak = mode == QuizMode.review ? app.progress.weakIds(pool) : null;
  final session = QuizSession.start(exam, pool, mode, onlyIds: weak);
  if (session.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(app.t(mode == QuizMode.review ? 'noWeak' : 'noQuestions'))));
    return;
  }
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => QuizScreen(session: session)))
      .then((_) => app.refresh());
}

/// Full card for one exam: icon, facts, readiness, Practice / Mock exam / review mistakes.
class ExamCard extends StatelessWidget {
  const ExamCard({super.key, required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final style = examStyle(exam.id);
    final pool = app.content.questionsFor(exam);
    final available = !exam.comingSoon && pool.isNotEmpty;
    final readiness = app.progress.readiness(pool);
    final weak = app.progress.weakIds(pool);

    void start(QuizMode mode) => startQuiz(context, exam, mode);

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
                if (available) ReadinessRing(value: readiness),
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
class ReadinessRing extends StatelessWidget {
  const ReadinessRing({super.key, required this.value});

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
