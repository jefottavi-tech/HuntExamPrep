import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import '../data/progress_store.dart';
import '../quiz/quiz_session.dart';
import 'exam_card.dart';

/// Daily goal ring, streak, and a one-tap "Practise now" on the user's main exam.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.mainExam});

  /// First of "my exams"; null hides the button.
  final Exam? mainExam;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    const goal = ProgressStore.dailyGoal;
    final done = app.progress.answeredToday();
    final streak = app.progress.streak;
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (done / goal).clamp(0, 1),
                          strokeWidth: 7,
                          backgroundColor: theme.colorScheme.surface,
                        ),
                      ),
                      done >= goal
                          ? Icon(Icons.check, color: theme.colorScheme.primary, size: 30)
                          : Text('$done', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.t('today'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        done >= goal
                            ? app.t('goalDone')
                            : app.t('goalProgress').replaceAll('{n}', '$done').replaceAll('{g}', '$goal'),
                        key: const Key('goal-text'),
                      ),
                      if (streak > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 18),
                              const SizedBox(width: 4),
                              Text(streak == 1 ? app.t('streakOne') : app.t('streakMany').replaceAll('{n}', '$streak')),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (mainExam case final exam?) ...[
              const SizedBox(height: 14),
              Text(
                exam.name(app.lang),
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              FilledButton.icon(
                key: const Key('today-practice'),
                onPressed: () => startQuiz(context, exam, QuizMode.practice),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(app.t('practiseNow')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
