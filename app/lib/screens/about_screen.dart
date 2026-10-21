import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/links.dart';
import '../data/sources.dart';

/// Disclaimer, how the app works, sources, contact and privacy.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _email = 'contact@kallistesoft.ca';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    Widget heading(String key) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(app.t(key), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
    Widget link(IconData icon, String label, Uri uri) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => tryOpen(uri),
    );
    return Scaffold(
      appBar: AppBar(title: Text(app.t('about'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Card(
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(app.t('disclaimer'), key: const Key('disclaimer')),
            ),
          ),
          heading('howItWorks'),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${app.t('practice')} : ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: app.t('howPractice')),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${app.t('examSim')} : ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: app.t('howExam')),
              ],
            ),
          ),
          heading('sources'),
          for (final m in manuals.values)
            link(Icons.menu_book_outlined, m.titles[app.lang] ?? m.titles['fr']!, Uri.parse(m.url)),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(app.t('photosCredit'), style: theme.textTheme.bodySmall),
          ),
          heading('contact'),
          link(Icons.mail_outline, _email, Uri(scheme: 'mailto', path: _email)),
          link(
            Icons.privacy_tip_outlined,
            app.t('privacy'),
            Uri.parse(
              app.lang == 'fr' ? 'https://kallistesoft.ca/confidentialite/' : 'https://kallistesoft.ca/en/privacy/',
            ),
          ),
        ],
      ),
    );
  }
}
