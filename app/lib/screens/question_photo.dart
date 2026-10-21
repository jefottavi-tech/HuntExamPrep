import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/links.dart';
import '../data/models.dart';

/// Photo of a "What is it?" question with the credit its free licence requires.
class QuestionPhoto extends StatelessWidget {
  const QuestionPhoto({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final credit = question.imageCredit;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(
            question.image!,
            key: const Key('question-photo'),
            fit: BoxFit.cover,
            semanticLabel: question.text(app.lang).q,
            errorBuilder: (_, _, _) => ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40)),
            ),
          ),
        ),
      ),
      if (credit != null)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            key: const Key('photo-credit'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: theme.textTheme.labelSmall,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () => tryOpen(Uri.parse(credit.page)),
            child: Text('${app.t('photoBy')}${credit.author}, ${credit.license}',
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
    ]);
  }
}

/// Small square thumbnail for lists (results screen).
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(image, width: 64, height: 64, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(width: 64, height: 64, child: Icon(Icons.image_outlined))),
      );
}
