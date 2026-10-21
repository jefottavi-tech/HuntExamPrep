/// Official study manuals the questions are written from, keyed by the file name
/// used in `sourceRef` ("cfsc_fr.pdf p.61").
class Manual {
  const Manual(this.titles, this.url);

  final Map<String, String> titles;
  final String url;
}

const manuals = {
  'cfsc_fr.pdf': Manual(
    {'fr': 'Manuel de l\'étudiant CCSMAF (GRC, 2014)', 'en': 'CFSC student manual (RCMP, 2014)'},
    'https://fedecp.com/media/2186/manuel-ccsmaf-francais-comprenant-la-section-sur-les-armes-a-feu-a-autorisation-restreinte.pdf',
  ),
  'icaf_fr.pdf': Manual({
    'fr': 'Manuel ICAF (FédéCP, 2020)',
    'en': 'ICAF manual (FédéCP, 2020)',
  }, 'https://fedecp.com/media/7535/icaf-fr-3-08-2020.pdf'),
  'ab_hunting_2026.pdf': Manual({
    'fr': 'Guide des règlements de chasse de l\'Alberta 2026',
    'en': '2026 Alberta Guide to Hunting Regulations',
  }, 'https://www.albertaregulations.ca/2026-Alberta-Hunting-Regulations.pdf'),
};

/// A readable source line and a link that opens the manual at the right PDF page.
class SourceRef {
  const SourceRef(this.label, this.uri);

  final String label;
  final Uri uri;

  static SourceRef? parse(String ref, String lang) {
    final m = RegExp(r'^(\S+) p\.(\d+)$').firstMatch(ref.trim());
    final manual = m == null ? null : manuals[m.group(1)];
    if (manual == null) return null;
    final page = m!.group(2);
    return SourceRef('${manual.titles[lang] ?? manual.titles['fr']}, p. $page', Uri.parse('${manual.url}#page=$page'));
  }
}
