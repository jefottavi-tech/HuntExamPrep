/// UI strings, French first. Small enough that a map beats code generation.
const _strings = <String, Map<String, String>>{
  'appTitle': {'fr': 'Examen PAL & Chasse', 'en': 'PAL & Hunting Exam Prep'},
  'pickerTitle': {'fr': 'Quel examen préparez-vous?', 'en': 'Which exam are you preparing for?'},
  'pickerSubtitle': {
    'fr': 'Choisissez un ou plusieurs tests. Vous pourrez changer plus tard.',
    'en': 'Pick one or more. You can change this later.',
  },
  'continue': {'fr': 'Continuer', 'en': 'Continue'},
  'skip': {'fr': 'Passer', 'en': 'Skip'},
  'myExams': {'fr': 'Mes examens', 'en': 'My exams'},
  'change': {'fr': 'Modifier', 'en': 'Change'},
  'otherTests': {'fr': 'Autres tests', 'en': 'Other tests'},
  'today': {'fr': 'Aujourd\'hui', 'en': 'Today'},
  'goalProgress': {'fr': '{n} / {g} questions aujourd\'hui', 'en': '{n} / {g} questions today'},
  'goalDone': {'fr': 'Objectif du jour atteint!', 'en': 'Today\'s goal reached!'},
  'goalHint': {'fr': 'Objectif : {g} questions par jour', 'en': 'Goal: {g} questions a day'},
  'practiseNow': {'fr': 'S\'exercer maintenant', 'en': 'Practise now'},
  'photoOfDay': {'fr': 'Photo du jour', 'en': 'Photo of the day'},
  'playId': {'fr': 'Jouer à « Qu\'est-ce que c\'est? »', 'en': 'Play "What is it?"'},
  'about': {'fr': 'À propos', 'en': 'About'},
  'footer': {
    'fr': 'Outil indépendant · non officiel · erreurs possibles.',
    'en': 'Independent tool · unofficial · errors possible.',
  },
  'learnMore': {'fr': 'En savoir plus', 'en': 'Learn more'},
  'howItWorks': {'fr': 'Comment ça marche', 'en': 'How it works'},
  'sources': {'fr': 'Sources', 'en': 'Sources'},
  'photosCredit': {
    'fr': 'Photos : Wikimedia Commons, sous licences libres. L\'auteur et la licence sont indiqués sous chaque photo.',
    'en': 'Photos: Wikimedia Commons, under free licences. Author and licence are shown under each photo.',
  },
  'contact': {'fr': 'Contact', 'en': 'Contact'},
  'privacy': {'fr': 'Politique de confidentialité', 'en': 'Privacy policy'},
  'howPractice': {
    'fr': 'Correction et explication après chaque question',
    'en': 'Answer and explanation after every question',
  },
  'howExam': {
    'fr': 'Chronométré, résultat à la fin, comme le vrai',
    'en': 'Timed, results at the end, like the real one',
  },
  'groupFirearms': {'fr': 'Permis d\'armes à feu', 'en': 'Firearms licence'},
  'groupHunting': {'fr': 'Éducation à la chasse', 'en': 'Hunter education'},
  'toPass': {'fr': '{p} % pour réussir', 'en': '{p}% to pass'},
  'minutes': {'fr': '{n} min', 'en': '{n} min'},
  'reviewMistakes': {'fr': 'Revoir mes erreurs', 'en': 'Review my mistakes'},
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
  'howRecognise': {'fr': 'Comment le reconnaître', 'en': 'How to recognise it'},
  'whereLives': {'fr': 'Où il vit', 'en': 'Where it lives'},
  'dontConfuse': {'fr': 'Ne pas confondre', 'en': 'Don\'t confuse it'},
  'zoomPhoto': {'fr': 'Agrandir la photo', 'en': 'Enlarge photo'},
  'photoBy': {'fr': 'Photo : ', 'en': 'Photo: '},
  'groupId': {'fr': 'Identification', 'en': 'Identification'},
  'why': {'fr': 'Pourquoi?', 'en': 'Why?'},
  'correct': {'fr': 'Bonne réponse!', 'en': 'Correct!'},
  'wrong': {'fr': 'Mauvaise réponse', 'en': 'Incorrect'},
  'question': {'fr': 'Question', 'en': 'Question'},
  'score': {'fr': 'Résultat', 'en': 'Score'},
  'passed': {'fr': 'Réussi', 'en': 'Passed'},
  'failed': {'fr': 'Échoué', 'en': 'Not passed'},
  'passMark': {'fr': 'Note de passage', 'en': 'Pass mark'},
  'missedTitle': {'fr': 'Questions à revoir', 'en': 'Questions to review'},
  'allCorrect': {'fr': 'Aucune erreur, bravo!', 'en': 'No mistakes, well done!'},
  'answer': {'fr': 'Bonne réponse : ', 'en': 'Correct answer: '},
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
    'fr':
        'Outil d\'étude indépendant, non affilié à la GRC, au Programme canadien des armes à feu, '
        'au gouvernement du Québec ni à la FédéCP, et non approuvé par eux. Les questions sont des '
        'questions de pratique originales, rédigées à partir des manuels officiels; ce ne sont pas les '
        'questions des examens officiels. Des erreurs sont possibles et les lois changent : vérifiez '
        'toujours dans le manuel officiel et la réglementation en vigueur. Aucune garantie de réussite.',
    'en':
        'Independent study aid, not affiliated with or endorsed by the RCMP, the Canadian Firearms '
        'Program, the Government of Québec or FédéCP. Questions are original practice questions based on '
        'the official manuals; they are not the official exam questions. Errors are possible and laws change: '
        'always check the official manual and current regulations. No guarantee of passing.',
  },
  'source': {'fr': 'Source :', 'en': 'Source:'},
  'speciesPage': {'fr': 'Fiche de l\'espèce', 'en': 'Species fact sheet'},
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
