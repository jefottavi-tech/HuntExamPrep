import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import 'about_screen.dart';
import 'exam_card.dart';
import 'exam_picker_screen.dart';
import 'exam_training_screen.dart';
import 'recognition_screen.dart';
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

    final exams = availableExams(app).where(isTrainingExam).toList();
    final mine = [
      for (final e in exams)
        if (chosen.contains(e.id)) e,
    ];
    final games = availableExams(app).where((e) => !isTrainingExam(e)).toList();
    final photoExam = games.where((e) => e.id == 'ID').firstOrNull;
    final readiness = mine.isEmpty
        ? 0.0
        : mine.map((e) => app.progress.readiness(app.content.questionsFor(e))).reduce((a, b) => a + b) / mine.length;
    final animals = photoExam == null ? 0 : app.content.questionsFor(photoExam).length;

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
          const SizedBox(height: 16),
          _HubCard(
            key: const Key('hub-exams'),
            icon: Icons.school_outlined,
            title: app.t('hubExams'),
            subtitle: app.t('hubExamsSub'),
            facts: [
              app.t('examsCount').replaceAll('{n}', '${exams.length}'),
              if (mine.isNotEmpty) '${app.t('readiness')} ${(readiness * 100).round()} %',
            ],
            color: scheme.primaryContainer,
            onColor: scheme.onPrimaryContainer,
            onTap: () => _open(context, const ExamTrainingScreen()),
          ),
          if (games.isNotEmpty) ...[
            const SizedBox(height: 12),
            _HubCard(
              key: const Key('hub-recognise'),
              icon: Icons.visibility_outlined,
              title: app.t('hubId'),
              subtitle: app.t('hubIdSub'),
              facts: [
                app.t(games.length == 1 ? 'gamesCount' : 'gamesCountMany').replaceAll('{n}', '${games.length}'),
                if (animals > 0) app.t('animalsCount').replaceAll('{n}', '$animals'),
              ],
              color: scheme.tertiaryContainer,
              onColor: scheme.onTertiaryContainer,
              onTap: () => _open(context, const RecognitionScreen()),
            ),
          ],
          if (photoExam != null) ...[const SizedBox(height: 16), PhotoOfDay(exam: photoExam)],
          const SizedBox(height: 20),
          _Footer(),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    final app = AppScope.of(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)).then((_) => app.refresh());
  }
}

/// Big entry card for a section of the app (exam training, recognition games…).
class _HubCard extends StatelessWidget {
  const _HubCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.facts,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> facts;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: onColor.withValues(alpha: 0.12),
                child: Icon(icon, size: 32, color: onColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: onColor),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: text.bodyMedium?.copyWith(color: onColor.withValues(alpha: 0.85))),
                    if (facts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        facts.join(' · '),
                        style: text.labelLarge?.copyWith(color: onColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: onColor),
            ],
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
