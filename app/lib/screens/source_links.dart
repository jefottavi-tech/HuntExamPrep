import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/links.dart';
import '../data/models.dart';
import '../data/sources.dart';

/// "Source" links under an explanation: the manual page, plus the official
/// page confirming the current rule when the question has one.
class SourceLinks extends StatelessWidget {
  const SourceLinks({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final manual = SourceRef.parse(question.sourceRef, app.lang);
    final rule = question.sourceUrl;
    if (manual == null && rule == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(app.t('source'), style: Theme.of(context).textTheme.labelMedium),
        if (manual != null) _Link(key: const Key('source-manual'), label: manual.label, uri: manual.uri),
        if (rule != null) _Link(key: const Key('source-rule'), label: app.t('currentRule'), uri: Uri.parse(rule)),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({super.key, required this.label, required this.uri});

  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
        onPressed: () => tryOpen(uri),
        icon: const Icon(Icons.open_in_new, size: 14),
        label: Text(label),
      );
}
