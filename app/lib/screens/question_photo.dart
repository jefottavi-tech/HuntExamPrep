import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/links.dart';
import '../data/models.dart';

/// Photo of a "What is it?" question with the credit its free licence requires.
class QuestionPhoto extends StatelessWidget {
  const QuestionPhoto({super.key, required this.question, this.maxHeightFactor = 0.42});

  final Question question;

  /// Tallest the photo may be, as a share of the screen height.
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final credit = question.imageCredit;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;
    final placeholder = ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Center(child: SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 3))),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The box has the photo's exact shape before it loads (no jump), capped so the choices stay on screen.
        LayoutBuilder(
          builder: (context, constraints) {
            final aspect = question.imageAspect ?? 4 / 3;
            var width = constraints.maxWidth;
            var height = width / aspect;
            if (height > maxHeight) (height, width) = (maxHeight, maxHeight * aspect);
            return Center(
              child: GestureDetector(
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => _FullPhoto(image: question.image!))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    key: const Key('photo-box'),
                    width: width,
                    height: height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          question.image!,
                          key: const Key('question-photo'),
                          fit: BoxFit.contain, // never crop: heads and tails must stay visible
                          semanticLabel: question.text(app.lang).q,
                          gaplessPlayback: true,
                          frameBuilder: (_, child, frame, syncLoaded) =>
                              syncLoaded || frame != null ? child : placeholder, // spinner while loading
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 40)),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black45,
                            child: Icon(
                              Icons.zoom_out_map,
                              size: 18,
                              color: Colors.white,
                              semanticLabel: app.t('zoomPhoto'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
