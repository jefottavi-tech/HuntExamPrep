/// UI strings, French first. Small enough that a map beats code generation.
const _strings = <String, Map<String, String>>{
  'appTitle': {'fr': 'Examen PAL & Chasse', 'en': 'PAL & Hunting Exam Prep'},
  'practice': {'fr': 'Pratique', 'en': 'Practice'},
  'examSim': {'fr': 'Examen simulé', 'en': 'Mock exam'},
  'review': {'fr': 'Révision', 'en': 'Review'},
  'comingSoon': {'fr': 'Bientôt disponible', 'en': 'Coming soon'},
  'questions': {'fr': 'questions', 'en': 'questions'},
  'readiness': {'fr': 'Préparation', 'en': 'Readiness'},
  'streakOne': {'fr': '1 jour de suite', 'en': '1-day streak'},
  'streakMany': {'fr': '{n} jours de suite', 'en': '{n}-day streak'},
  'next': {'fr': 'Suivant', 'en': 'Next'},
  'finish': {'fr': 'Terminer', 'en': 'Finish'},
  'correct': {'fr': 'Bonne réponse!', 'en': 'Correct!'},
  'wrong': {'fr': 'Mauvaise réponse', 'en': 'Incorrect'},
  'question': {'fr': 'Question', 'en': 'Question'},
  'score': {'fr': 'Résultat', 'en': 'Score'},
  'passed': {'fr': 'Réussi', 'en': 'Passed'},
  'failed': {'fr': 'Échoué', 'en': 'Not passed'},
  'passMark': {'fr': 'Note de passage', 'en': 'Pass mark'},
  'missedTitle': {'fr': 'Questions à revoir', 'en': 'Questions to review'},
  'allCorrect': {'fr': 'Aucune erreur, bravo!', 'en': 'No mistakes, well done!'},
  'answer': {'fr': 'Réponse : ', 'en': 'Answer: '},
  'again': {'fr': 'Recommencer', 'en': 'Try again'},
  'home': {'fr': 'Accueil', 'en': 'Home'},
  'noQuestions': {'fr': 'Aucune question disponible.', 'en': 'No questions available.'},
  'noWeak': {'fr': 'Aucune question à revoir pour l\'instant.', 'en': 'Nothing to review yet.'},
  'timeUp': {'fr': 'Temps écoulé', 'en': 'Time is up'},
  'sampleBanner': {
    'fr': 'Contenu d\'exemple, non révisé. Ne pas utiliser pour étudier.',
    'en': 'Sample content, not reviewed. Do not use to study.',
  },
  'disclaimer': {
    'fr': 'Outil d\'étude indépendant, non affilié à la GRC, au Programme canadien des armes à feu, '
        'au gouvernement du Québec ni à la FédéCP, et non approuvé par eux. Les questions sont des '
        'questions de pratique originales, rédigées à partir des manuels officiels; ce ne sont pas les '
        'questions des examens officiels. Des erreurs sont possibles et les lois changent : vérifiez '
        'toujours dans le manuel officiel et la réglementation en vigueur. Aucune garantie de réussite.',
    'en': 'Independent study aid, not affiliated with or endorsed by the RCMP, the Canadian Firearms '
        'Program, the Government of Québec or FédéCP. Questions are original practice questions based on '
        'the official manuals; they are not the official exam questions. Errors are possible and laws change: '
        'always check the official manual and current regulations. No guarantee of passing.',
  },
  'source': {'fr': 'Source :', 'en': 'Source:'},
  'currentRule': {'fr': 'Règle officielle à jour', 'en': 'Current official rule'},
  'yourAnswer': {'fr': 'Votre réponse : ', 'en': 'Your answer: '},
  'report': {'fr': 'Signaler un problème', 'en': 'Report a problem'},
  'reportSubject': {'fr': 'Erreur dans une question', 'en': 'Problem with a question'},
  'reportBody': {
    'fr': 'Décrivez le problème (erreur, règle changée, traduction…) :\n\n\n',
    'en': 'Describe the problem (error, rule change, translation…):\n\n\n',
  },
  'reportFallback': {'fr': 'Écrivez-nous à {email} (question {id})', 'en': 'Email us at {email} (question {id})'},
  'quitTitle': {'fr': 'Quitter le test?', 'en': 'Quit this test?'},
  'quitBody': {'fr': 'Votre progression dans ce test sera perdue.', 'en': 'Your progress in this test will be lost.'},
  'quit': {'fr': 'Quitter', 'en': 'Quit'},
  'cancel': {'fr': 'Annuler', 'en': 'Cancel'},
};

String tr(String lang, String key) => _strings[key]?[lang] ?? _strings[key]?['fr'] ?? key;
