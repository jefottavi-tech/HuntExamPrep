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
    final image = Image.asset(
      question.image!,
      key: const Key('question-photo'),
      fit: BoxFit.contain, // never crop: heads and tails must stay visible
      semanticLabel: question.text(app.lang).q,
      errorBuilder: (_, _, _) => SizedBox(
        height: 200,
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40)),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Whole photo at its own shape; tall photos are capped so the choices stay on screen.
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.42),
          child: Center(
            heightFactor: 1, // as tall as the photo, so the credit sits right under it
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => _FullPhoto(image: question.image!))),
              child: Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black45,
                      child: Icon(Icons.zoom_out_map, size: 18, color: Colors.white, semanticLabel: app.t('zoomPhoto')),
                    ),
                  ),
                ],
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
              child: Text(
                '${app.t('photoBy')}${credit.author}, ${credit.license}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}

/// Full-screen photo with pinch-to-zoom.
class _FullPhoto extends StatelessWidget {
  const _FullPhoto({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
    body: InteractiveViewer(
      maxScale: 5,
      child: Center(child: Image.asset(image, fit: BoxFit.contain)),
    ),
  );
}

/// Small thumbnail for lists (results screen); whole photo, never cropped.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Image.asset(image, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.image_outlined)),
      ),
    ),
  );
}
