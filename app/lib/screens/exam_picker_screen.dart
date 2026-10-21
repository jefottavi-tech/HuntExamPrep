import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import 'exam_card.dart';

/// "Which exam are you preparing for?": shown on first launch and from "Change" on the dashboard.
class ExamPickerScreen extends StatefulWidget {
  const ExamPickerScreen({super.key, this.firstRun = false});

  /// First launch: no back button, and saving rebuilds the dashboard in place.
  final bool firstRun;

  @override
  State<ExamPickerScreen> createState() => _ExamPickerScreenState();
}

class _ExamPickerScreenState extends State<ExamPickerScreen> {
  late final Set<String> _chosen = {...?AppScope.of(context).progress.myExams};

  Future<void> _save(List<String> ids) async {
    final app = AppScope.of(context);
    final navigator = Navigator.of(context);
    await app.progress.setMyExams(ids);
    app.refresh();
    if (!widget.firstRun && navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final exams = availableExams(app).where(isTrainingExam).toList(); // recognition games aren't exams
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: !widget.firstRun),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(app.t('pickerTitle'), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(app.t('pickerSubtitle'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          for (final g in ExamGroup.values)
            if (exams.where((e) => examStyle(e.id).group == g).toList() case final group when group.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                app.t(g.titleKey).toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              for (final exam in group)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _Choice(
                    key: Key('picker-${exam.id}'),
                    icon: examStyle(exam.id).icon,
                    title: exam.name(app.lang),
                    subtitle:
                        '${examStyle(exam.id).region} · ${app.content.questionsFor(exam).length} ${app.t('questions')}',
                    selected: _chosen.contains(exam.id),
                    onTap: () =>
                        setState(() => _chosen.contains(exam.id) ? _chosen.remove(exam.id) : _chosen.add(exam.id)),
                  ),
                ),
            ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (widget.firstRun)
                TextButton(
                  key: const Key('picker-skip'),
                  onPressed: () => _save([for (final e in exams) e.id]),
                  child: Text(app.t('skip')),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  key: const Key('picker-continue'),
                  onPressed: _chosen.isEmpty
                      ? null
                      : () => _save([
                          for (final e in exams)
                            if (_chosen.contains(e.id)) e.id,
                        ]), // keep display order
                  child: Text(app.t('continue')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: scheme.surface,
          child: Icon(icon, color: scheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? scheme.primary : null),
        onTap: onTap,
      ),
    );
  }
}
