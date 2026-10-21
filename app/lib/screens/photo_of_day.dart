import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import '../data/progress_store.dart';
import '../quiz/quiz_session.dart';
import 'exam_card.dart';
import 'question_photo.dart';

/// One "What is it?" photo per day, answered right on the dashboard.
class PhotoOfDay extends StatelessWidget {
  const PhotoOfDay({super.key, required this.exam});

  /// The photo ID exam ("ID"); its bank supplies the photo.
  final Exam exam;

  /// Same question all day for everyone: the day number picks it.
  static Question? pick(List<Question> pool, DateTime now) =>
      pool.isEmpty ? null : pool[ProgressStore.dayNumber(now) % pool.length];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final q = pick(app.content.questionsFor(exam), DateTime.now());
    if (q == null) return const SizedBox.shrink();
    final text = q.text(app.lang);
    final chosen = app.progress.photoOfDayChoice();
    final right = chosen == q.answerIndex;

    Future<void> answer(int i) async {
      await app.progress.setPhotoOfDayChoice(i);
      await app.progress.record(q, i == q.answerIndex); // counts toward the goal, streak and weak spots
      app.refresh();
    }

    return Card(
      key: const Key('photo-of-day'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.photo_camera_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(app.t('photoOfDay'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            QuestionPhoto(question: q, maxHeightFactor: 0.3),
            const SizedBox(height: 8),
            Text(text.q, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.2,
              children: [
                for (var i = 0; i < text.choices.length; i++)
                  _Choice(
                    key: Key('pod-choice-$i'),
                    label: text.choices[i],
                    // After answering: the right one in green, a wrong pick in red.
                    color: chosen == null
                        ? null
                        : i == q.answerIndex
                        ? Colors.green.shade600
                        : i == chosen
                        ? theme.colorScheme.error
                        : null,
                    onTap: chosen == null ? () => answer(i) : null,
                  ),
              ],
            ),
            if (chosen != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    right ? Icons.check_circle : Icons.cancel,
                    color: right ? Colors.green.shade600 : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    app.t(right ? 'correct' : 'wrong'),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(app.t('howRecognise'), style: theme.textTheme.labelLarge),
              Text(text.explanation),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('pod-play'),
                onPressed: () => startQuiz(context, exam, QuizMode.practice),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(app.t('playId')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({super.key, required this.label, required this.color, required this.onTap});

  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color?.withValues(alpha: 0.15) ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color ?? scheme.outlineVariant, width: color == null ? 1 : 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
