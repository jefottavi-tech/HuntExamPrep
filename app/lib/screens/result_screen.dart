import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../quiz/quiz_session.dart';
import 'question_photo.dart';
import 'quiz_screen.dart';
import 'source_links.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.session, this.timeUp = false});

  final QuizSession session;
  final bool timeUp;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final s = session;
    final isExam = s.mode == QuizMode.exam;
    final pct = (s.score * 100).round();
    final color = !isExam ? theme.colorScheme.primary : (s.passed ? Colors.green.shade700 : theme.colorScheme.error);

    void again() {
      final pool = app.content.questionsFor(s.exam);
      final weak = s.mode == QuizMode.review ? app.progress.weakIds(pool) : null;
      final next = QuizSession.start(s.exam, pool, s.mode, onlyIds: weak);
      if (next.isEmpty) return Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(session: next)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(app.t('score')), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (timeUp) Text(app.t('timeUp'), textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: s.score,
                      strokeWidth: 12,
                      color: color,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$pct %',
                        key: const Key('score'),
                        style: theme.textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                      ),
                      Text('${s.correctCount} / ${s.questions.length}', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExam) ...[
            const SizedBox(height: 16),
            Center(
              child: Chip(
                avatar: Icon(s.passed ? Icons.verified : Icons.error_outline, color: color, size: 20),
                label: Text(
                  '${app.t(s.passed ? 'passed' : 'failed')} · ${app.t('passMark')} ${(s.exam.passMark * 100).round()} %',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                side: BorderSide(color: color),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(app.t('missedTitle'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (s.missed.isEmpty) Text(app.t('allCorrect')),
          for (final (q, picked) in s.missedWithAnswers)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (q.image != null) ...[PhotoThumb(image: q.image!), const SizedBox(height: 8)],
                    Text(q.text(app.lang).q, style: theme.textTheme.titleSmall),
                    if (picked != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${app.t('yourAnswer')}${q.text(app.lang).choices[picked]}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${app.t('answer')}${q.text(app.lang).choices[q.answerIndex]}',
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(q.text(app.lang).explanation, style: theme.textTheme.bodySmall),
                    SourceLinks(question: q),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(app.t('home'))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(key: const Key('again'), onPressed: again, child: Text(app.t('again'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
