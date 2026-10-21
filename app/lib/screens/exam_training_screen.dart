import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import 'exam_card.dart';
import 'exam_picker_screen.dart';

/// "Exam training": the user's exams as full cards, the other exams as compact rows.
class ExamTrainingScreen extends StatelessWidget {
  const ExamTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final chosen = app.progress.myExams ?? const [];
    final exams = availableExams(app).where(isTrainingExam).toList();
    final mine = [
      for (final e in exams)
        if (chosen.contains(e.id)) e,
    ];
    final others = [
      for (final e in exams)
        if (!chosen.contains(e.id)) e,
    ];

    Widget section(String title, {Widget? action}) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, letterSpacing: 0.8),
            ),
          ),
          ?action,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(app.t('hubExams'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          section(
            app.t('myExams'),
            action: TextButton.icon(
              key: const Key('change-exams'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamPickerScreen())),
              icon: const Icon(Icons.tune, size: 18),
              label: Text(app.t('change')),
            ),
          ),
          for (final exam in mine) ...[ExamCard(exam: exam), const SizedBox(height: 12)],
          if (others.isNotEmpty) ...[
            section(app.t('otherTests')),
            Card(
              child: Column(
                children: [
                  for (final (i, exam) in others.indexed) ...[
                    if (i > 0) const Divider(height: 1, indent: 72),
                    _OtherExamRow(exam: exam),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact row for an exam the user isn't preparing; opens its full card in a sheet.
class _OtherExamRow extends StatelessWidget {
  const _OtherExamRow({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = examStyle(exam.id);
    return ListTile(
      key: Key('other-${exam.id}'),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(style.icon, color: scheme.onPrimaryContainer),
      ),
      title: Text(exam.name(app.lang), style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${style.region} · ${app.content.questionsFor(exam).length} ${app.t('questions')}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ExamCard(exam: exam),
          ),
        ),
      ),
    );
  }
}
