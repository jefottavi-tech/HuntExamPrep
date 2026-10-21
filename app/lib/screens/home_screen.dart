import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../data/models.dart';
import 'about_screen.dart';
import 'exam_card.dart';
import 'exam_picker_screen.dart';
import 'photo_of_day.dart';
import 'today_card.dart';

/// Dashboard built around the exams the user is preparing for. On first launch it shows the picker instead.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final chosen = app.progress.myExams;
    if (chosen == null) return const ExamPickerScreen(firstRun: true);

    // Section order (firearms, hunting, identification), then exams.json order within a section.
    final available = [
      for (final e in app.content.exams)
        if (!e.comingSoon && app.content.questionsFor(e).isNotEmpty) e,
    ]..sort((a, b) => examStyle(a.id).group.index.compareTo(examStyle(b.id).group.index));
    final mine = [
      for (final e in available)
        if (chosen.contains(e.id)) e,
    ];
    final others = [
      for (final e in available)
        if (!chosen.contains(e.id)) e,
    ];
    final photoExam = available.where((e) => e.id == 'ID').firstOrNull;

    Widget section(String title, {Widget? action}) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary, letterSpacing: 0.8),
            ),
          ),
          ?action,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('appTitle'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          SegmentedButton<String>(
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
          IconButton(
            key: const Key('about'),
            tooltip: app.t('about'),
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
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
          TodayCard(mainExam: mine.firstOrNull),
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
          if (photoExam != null) ...[const SizedBox(height: 12), PhotoOfDay(exam: photoExam)],
          if (others.isNotEmpty) ...[
            section(app.t('otherTests')),
            Card(
              child: Column(
                children: [
                  for (final (i, exam) in others.indexed) ...[
                    if (i > 0) const Divider(height: 1, indent: 72),
                    _OtherTestRow(exam: exam),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _Footer(),
        ],
      ),
    );
  }
}

/// Compact row for an exam the user isn't preparing; opens its full card in a sheet.
class _OtherTestRow extends StatelessWidget {
  const _OtherTestRow({required this.exam});

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

/// The three legal points, always visible, with a link to the full text in About.
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(app.t('footer'), key: const Key('footer'), style: muted),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          child: Text(app.t('learnMore')),
        ),
      ],
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
