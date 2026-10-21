import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external links (sources, report emails). Tests swap it out because the
/// platform plugin is absent there.
@visibleForTesting
Future<bool> Function(Uri) openUrl = launchUrl;

/// Opens [uri], returning false instead of throwing when nothing can handle it.
Future<bool> tryOpen(Uri uri) async {
  try {
    return await openUrl(uri);
  } catch (_) {
    return false;
  }
}
