import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/links.dart';
import '../quiz/quiz_session.dart';
import 'result_screen.dart';
import 'question_photo.dart';
import 'source_links.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.session});

  final QuizSession session;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizSession get s => widget.session;
  bool get isExam => s.mode == QuizMode.exam;

  Timer? _timer;
  late Duration _left = Duration(minutes: s.exam.minutes);

  @override
  void initState() {
    super.initState();
    if (isExam) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _left -= const Duration(seconds: 1));
        if (_left <= Duration.zero) _finish(timeUp: true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _choose(int choice) async {
    final app = AppScope.of(context);
    if (!isExam && s.currentAnswered) return;
    final correct = s.answer(choice);
    setState(() {});
    // Exam answers can still change, so they are recorded at the end.
    if (!isExam) await app.progress.record(s.question, correct);
  }

  Future<void> _next() async {
    if (s.isLast) return _finish();
    setState(s.next);
  }

  Future<void> _finish({bool timeUp = false}) async {
    _timer?.cancel();
    final app = AppScope.of(context);
    final navigator = Navigator.of(context);
    if (isExam) {
      for (var i = 0; i < s.questions.length; i++) {
        final a = s.answerAt(i);
        if (a != null) await app.progress.record(s.questions[i], a == s.questions[i].answerIndex);
      }
    }
    await app.ads.showInterstitial();
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(session: s, timeUp: timeUp),
      ),
    );
  }

  static const _reportEmail = 'contact@kallistesoft.ca';

  /// Opens a pre-filled email about the current question; no backend needed.
  Future<void> _report() async {
    final app = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final q = s.question;
    final text = q.text(app.lang);
    final body =
        '${app.t('reportBody')}---\n${q.id} (${q.sourceRef})\n${text.q}\n'
        '${[for (var i = 0; i < text.choices.length; i++) '${'ABCD'[i]}. ${text.choices[i]}'].join('\n')}';
    final uri = Uri(
      scheme: 'mailto',
      path: _reportEmail,
      // Uri's queryParameters encodes spaces as '+', which mail apps show literally.
      query: 'subject=${Uri.encodeComponent('${app.t('reportSubject')} ${q.id}')}&body=${Uri.encodeComponent(body)}',
    );
    if (!await tryOpen(uri)) {
      messenger.showSnackBar(
        SnackBar(content: Text(app.t('reportFallback').replaceAll('{email}', _reportEmail).replaceAll('{id}', q.id))),
      );
    }
  }

  Future<bool> _confirmQuit() async {
    final app = AppScope.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(app.t('quitTitle')),
            content: Text(app.t('quitBody')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(app.t('cancel'))),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(app.t('quit'))),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    final q = s.question;
    final text = q.text(app.lang);
    final chosen = s.answerAt(s.current);
    final showFeedback = !isExam && chosen != null;

    // Load the next photo while this question is read, so it appears without a wait.
    final nextPhoto = s.isLast ? null : s.questions[s.current + 1].image;
    if (nextPhoto != null) precacheImage(AssetImage(nextPhoto), context);

    final feedback = Card(
      key: const Key('feedback'),
      color: (chosen == q.answerIndex ? Colors.green : theme.colorScheme.error).withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  chosen == q.answerIndex ? Icons.check_circle : Icons.cancel,
                  color: chosen == q.answerIndex ? Colors.green.shade600 : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  app.t(chosen == q.answerIndex ? 'correct' : 'wrong'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: chosen == q.answerIndex ? Colors.green.shade600 : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(app.t(q.image != null ? 'howRecognise' : 'why'), style: theme.textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(text.explanation),
            if (text.habitat != null) ...[
              const SizedBox(height: 10),
              Text(app.t('whereLives'), style: theme.textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(text.habitat!),
            ],
            if (text.confuse != null) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${app.t('dontConfuse')} : ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: text.confuse),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            SourceLinks(question: q),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmQuit()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${app.t('question')} ${s.current + 1}/${s.questions.length}'),
          actions: [
            IconButton(
              key: const Key('report'),
              tooltip: app.t('report'),
              icon: const Icon(Icons.flag_outlined),
              onPressed: _report,
            ),
            if (isExam)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_left.inMinutes}:${(_left.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: _left.inMinutes < 5 ? theme.colorScheme.error : null,
                    ),
                  ),
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (s.current + 1) / s.questions.length),
          ),
        ),
        body: SafeArea(
          child: ListView(
            key: ValueKey(s.current), // each question starts scrolled to the top
            padding: const EdgeInsets.all(16),
            children: [
              if (q.image != null) ...[
                QuestionPhoto(question: q),
                const SizedBox(height: 12),
                // Photo questions: the animal's card goes right under the photo, where the eye already is.
                if (showFeedback) ...[feedback, const SizedBox(height: 16)],
              ],
              Text(text.q, style: theme.textTheme.titleLarge?.copyWith(height: 1.3)),
              const SizedBox(height: 20),
              for (var i = 0; i < text.choices.length; i++)
                _ChoiceTile(
                  key: Key('choice-$i'),
                  letter: 'ABCD'[i],
                  label: text.choices[i],
                  state: switch ((showFeedback, isExam)) {
                    (true, _) when i == q.answerIndex => _ChoiceState.correct,
                    (true, _) when i == chosen => _ChoiceState.wrong,
                    (false, true) when i == chosen => _ChoiceState.selected,
                    _ => _ChoiceState.idle,
                  },
                  onTap: () => _choose(i),
                ),
              if (showFeedback && q.image == null) ...[const SizedBox(height: 8), feedback],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('next'),
              onPressed: chosen == null ? null : _next,
              child: Text(app.t(s.isLast ? 'finish' : 'next')),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ChoiceState { idle, selected, correct, wrong }

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({super.key, required this.letter, required this.label, required this.state, required this.onTap});

  final String letter;
  final String label;
  final _ChoiceState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (border, fill, icon) = switch (state) {
      _ChoiceState.idle => (scheme.outlineVariant, null, null),
      _ChoiceState.selected => (scheme.primary, scheme.primaryContainer, null),
      _ChoiceState.correct => (Colors.green.shade600, Colors.green.withValues(alpha: 0.12), Icons.check_circle),
      _ChoiceState.wrong => (scheme.error, scheme.error.withValues(alpha: 0.12), Icons.cancel),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: fill ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: state == _ChoiceState.idle ? 1 : 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(radius: 14, child: Text(letter, style: const TextStyle(fontSize: 13))),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
                if (icon != null) Icon(icon, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
