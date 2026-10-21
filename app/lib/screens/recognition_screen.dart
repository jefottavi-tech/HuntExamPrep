import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import 'exam_card.dart';

/// "Can you recognise them?": identification games (photo quiz today; tracks, calls… later).
class RecognitionScreen extends StatelessWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final games = availableExams(app).where((e) => !isTrainingExam(e)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(app.t('hubId'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(app.t('hubIdSub'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          for (final game in games) ...[ExamCard(exam: game), const SizedBox(height: 12)],
        ],
      ),
    );
  }
}
