// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Routes d\'Escalade';

  @override
  String get navRoutes => 'Voies';

  @override
  String get navProfile => 'Profil';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Ajouter';

  @override
  String get update => 'Mettre à jour';

  @override
  String get remove => 'Supprimer';

  @override
  String get search => 'Rechercher';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get username => 'Nom d\'utilisateur (pour la connexion)';

  @override
  String get nickname => 'Pseudonyme (nom d\'affichage public)';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get pleaseEnterUsername => 'Veuillez saisir votre nom d\'utilisateur';

  @override
  String get pleaseEnterNickname => 'Veuillez saisir votre pseudonyme';

  @override
  String get pleaseEnterEmail => 'Veuillez saisir votre email';

  @override
  String get pleaseEnterPassword => 'Veuillez saisir votre mot de passe';

  @override
  String get usernameMinLength => 'Le nom d\'utilisateur doit contenir au moins 3 caractères';

  @override
  String get nicknameLength => 'Le pseudonyme doit contenir 3 à 20 caractères';

  @override
  String get nicknameFormat => 'Seuls les lettres, chiffres et underscores sont autorisés';

  @override
  String get emailInvalid => 'Veuillez saisir une adresse email valide';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get createAccountButton => 'Créer un compte';

  @override
  String get switchToRegister => 'Pas de compte ? Inscrivez-vous';

  @override
  String get switchToLogin => 'Déjà un compte ? Connectez-vous';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editNickname => 'Modifier le pseudonyme';

  @override
  String get editNicknameTooltip => 'Modifier le pseudonyme';

  @override
  String get nicknameUpdated => 'Pseudonyme mis à jour';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String memberSince(String date) {
    return 'Membre depuis le $date';
  }

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get languageSettings => 'Langue';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get account => 'Compte';

  @override
  String get performanceTab => 'Performance';

  @override
  String get routesTab => 'Voies';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get ticksTab => 'Réalisations';

  @override
  String get likesTab => 'Favoris';

  @override
  String get projectsTab => 'Projets';

  @override
  String get noTicksFound => 'Aucune réalisation trouvée';

  @override
  String get noTicksDescription => 'Terminez quelques voies pour les voir ici';

  @override
  String get noLikesFound => 'Aucune voie aimée trouvée';

  @override
  String get noLikesDescription => 'Aimez quelques voies pour les voir ici';

  @override
  String get noProjectsFound => 'Aucun projet trouvé';

  @override
  String get noProjectsDescription => 'Marquez des voies comme projets pour suivre vos objectifs';

  @override
  String get gradeBreakdown => 'Répartition par cotation';

  @override
  String get hardestGrade => 'Cotation la plus difficile';

  @override
  String get totalTicks => 'Réalisations totales';

  @override
  String get totalAttempts => 'Tentatives moy.';

  @override
  String get topRopeFlash => 'Moulinette flash';

  @override
  String get leadFlash => 'Tête flash';

  @override
  String get flashRate => 'Taux de flash';

  @override
  String get averageAttempts => 'Tentatives moy.';

  @override
  String get routeTitle => 'Détails de la voie';

  @override
  String get addRoute => 'Ajouter une voie';

  @override
  String get routeName => 'Nom de la voie';

  @override
  String get routeNameRequired => 'Le nom de la voie est requis';

  @override
  String get routeNameHelper => 'Donnez un nom mémorable à votre voie';

  @override
  String get grade => 'Cotation';

  @override
  String get gradeRequired => 'La cotation est requise';

  @override
  String get gradeHelper => 'Sélectionnez la cotation de difficulté';

  @override
  String get routeSetter => 'Ouvreur';

  @override
  String get routeSetterRequired => 'Le nom de l\'ouvreur est requis';

  @override
  String get routeSetterHelper => 'Nom de la personne qui a ouvert cette voie';

  @override
  String get wallSection => 'Section du mur';

  @override
  String get wallSectionRequired => 'La section du mur est requise';

  @override
  String get wallSectionHelper => 'Quelle section du mur d\'escalade';

  @override
  String get lane => 'Couloir';

  @override
  String get laneRequired => 'Le couloir est requis';

  @override
  String get laneHelper => 'Numéro du couloir sur le mur';

  @override
  String laneNumber(int number) {
    return 'Couloir $number';
  }

  @override
  String get holdColor => 'Couleur des prises';

  @override
  String get holdColorHelper => 'Couleur des prises de la voie (optionnel)';

  @override
  String get noSpecificColor => 'Aucune couleur spécifique';

  @override
  String get routeDescription => 'Description';

  @override
  String get routeDescriptionHelper => 'Détails supplémentaires sur la voie (optionnel)';

  @override
  String setBy(String setter) {
    return 'Ouverte par $setter';
  }

  @override
  String get unknownRoute => 'Voie inconnue';

  @override
  String get addNewRoute => 'Ajouter une nouvelle voie';

  @override
  String get routeInformation => 'Informations de la voie';

  @override
  String get createRoute => 'Créer la voie';

  @override
  String get creatingRoute => 'Création de la voie...';

  @override
  String get routeCreatedSuccess => 'Voie créée avec succès !';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get enterCreativeName => 'Entrez un nom créatif pour la voie';

  @override
  String get selectDifficultyGrade => 'Sélectionnez la cotation de difficulté';

  @override
  String get nameOfPersonWhoSet => 'Nom de la personne qui a ouvert cette voie';

  @override
  String get locationOfRouteInGym => 'Emplacement de la voie dans la salle';

  @override
  String get selectLaneNumber => 'Sélectionnez le numéro de la voie';

  @override
  String get colorOfRouteHolds => 'Couleur des prises de la voie (optionnel)';

  @override
  String get optionalDescriptionRoute => 'Description optionnelle du style ou des caractéristiques de la voie';

  @override
  String get markSend => 'Marquer comme réalisée';

  @override
  String get addProgress => 'Ajouter un progrès';

  @override
  String get addAttempts => 'Ajouter des tentatives';

  @override
  String get reportIssue => 'Signaler un problème';

  @override
  String get sendType => 'Type de réalisation :';

  @override
  String get topRope => 'Moulinette';

  @override
  String get lead => 'Tête';

  @override
  String get notes => 'Notes :';

  @override
  String get notesHelper => 'Ajoutez des notes sur votre réalisation (optionnel)';

  @override
  String get addTimestamp => 'Ajouter un timestamp';

  @override
  String attempts(int count) {
    return 'Tentatives :';
  }

  @override
  String attemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tentatives',
      one: 'tentative',
    );
    return '$count $_temp0';
  }

  @override
  String get attemptsHelper => 'Combien de tentatives cela a-t-il pris ?';

  @override
  String get issueType => 'Type de problème';

  @override
  String get brokenHold => 'Prise cassée';

  @override
  String get safetyIssue => 'Problème de sécurité';

  @override
  String get needsCleaning => 'Nécessite un nettoyage';

  @override
  String get looseHold => 'Prise descellée';

  @override
  String get other => 'Autre';

  @override
  String get issueDescription => 'Description';

  @override
  String get issueDescriptionHelper => 'Décrivez le problème';

  @override
  String get submitReport => 'Soumettre le rapport';

  @override
  String get projectRoute => 'Ajouter aux projets';

  @override
  String get removeProject => 'Retirer des projets';

  @override
  String get likeRoute => 'Aimer';

  @override
  String get unlikeRoute => 'Ne plus aimer';

  @override
  String get progressTracking => 'Suivi des Progrès';

  @override
  String get socialPlanning => 'Social & Planification';

  @override
  String get feedbackReporting => 'Commentaires & Signalements';

  @override
  String get alreadySent => 'Déjà Enchaînée';

  @override
  String get cannotAddAttempts => 'Impossible d\'ajouter des tentatives aux voies déjà enchaînées en tête.';

  @override
  String get attemptsLabel => 'Tentatives';

  @override
  String get topRopeLabel => 'Moulinette';

  @override
  String get flashLabel => 'Flash !';

  @override
  String get liked => 'Aimée';

  @override
  String get like => 'Aimer';

  @override
  String get project => 'Projet';

  @override
  String get addProject => 'Ajouter aux Projets';

  @override
  String get topRopeSent => 'Moulinette Enchaînée';

  @override
  String get leadSent => 'Tête Enchaînée';

  @override
  String get suggestGrade => 'Suggérer une Cotation';

  @override
  String get issueTypeOptional => 'Type de Problème (Optionnel)';

  @override
  String get topRopeShort => 'MOU';

  @override
  String get leadShort => 'Tête';

  @override
  String get flash => '⚡';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterThisWeek => 'Cette semaine';

  @override
  String get filterThisMonth => 'Ce mois';

  @override
  String get filterThisYear => 'Cette année';

  @override
  String get filterLast3Months => '3 derniers mois';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中文';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorBlack => 'Noir';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorGray => 'Gris';

  @override
  String get colorBrown => 'Marron';

  @override
  String get interactions => 'Interactions';

  @override
  String get yourProgress => 'Votre progression';

  @override
  String get removeTick => 'Supprimer la coche';

  @override
  String get addNotesAttempts => 'Ajouter des notes sur vos tentatives';

  @override
  String get addEntryBelowNotes => 'Ajouter une entrée sous les notes existantes';

  @override
  String get addNotesSend => 'Ajouter des notes sur cet enchaînement';

  @override
  String markedSend(String sendType) {
    return 'Enchaînement $sendType marqué !';
  }

  @override
  String get yourComment => 'Votre commentaire';

  @override
  String get proposedGrade => 'Cotation proposée';

  @override
  String get selectGradeToPropose => 'Sélectionner une cotation à proposer';

  @override
  String get changeProposedGrade => 'Vous pouvez modifier votre cotation proposée';

  @override
  String get attemptAdded => 'Tentative ajoutée !';

  @override
  String get failedToAddAttempt => 'Échec de l\'ajout de tentative';

  @override
  String get topRopeSendRemoved => 'Enchaînement moulinette supprimé !';

  @override
  String get failedToRemoveTopRopeSend => 'Échec de la suppression de l\'enchaînement moulinette';

  @override
  String get topRopeSendMarked => 'Enchaînement moulinette marqué !';

  @override
  String get failedToMarkTopRopeSend => 'Échec du marquage de l\'enchaînement moulinette';

  @override
  String get leadSendRemoved => 'Enchaînement en tête supprimé !';

  @override
  String get failedToRemoveLeadSend => 'Échec de la suppression de l\'enchaînement en tête';

  @override
  String get leadSendMarked => 'Enchaînement en tête marqué !';

  @override
  String get failedToMarkLeadSend => 'Échec du marquage de l\'enchaînement en tête';

  @override
  String get routeUnliked => 'Voie plus aimée !';

  @override
  String get routeLiked => 'Voie aimée !';

  @override
  String get cannotMarkSentRoutesAsProjects => 'Impossible de marquer les voies enchaînées comme projets';

  @override
  String get projectRemoved => 'Projet supprimé !';

  @override
  String get routeAddedToProjects => 'Voie ajoutée aux projets !';

  @override
  String get commentAdded => 'Commentaire ajouté !';

  @override
  String get gradeProposalUpdated => 'Proposition de cotation mise à jour !';

  @override
  String get issueReported => 'Problème signalé !';

  @override
  String get unableToLoadGrades => 'Impossible de charger les cotations';

  @override
  String get gradeDefinitions => 'Définitions des cotations';

  @override
  String get gradesList => 'Liste des cotations';

  @override
  String get updateGradeProposal => 'Mettre à Jour la Proposition de Cotation';

  @override
  String get youAlreadyProposed => 'Vous avez déjà proposé';

  @override
  String get changeYourGradeAndUpdateReasoningBelow => 'Changez votre cotation et mettez à jour le raisonnement ci-dessous';

  @override
  String get youHadAPreviousProposalThatIsNoLongerValid => 'Vous aviez une proposition précédente qui n\'est plus valide';

  @override
  String get pleaseSelectANewGrade => 'Veuillez sélectionner une nouvelle cotation';

  @override
  String get reasoningOptional => 'Raisonnement (Optionnel)';

  @override
  String get errorLoadingGradeProposalDialog => 'Erreur lors du chargement du dialogue de proposition de cotation';

  @override
  String get overhangWall => 'Mur en surplomb';

  @override
  String get slabWall => 'Mur en dalle';

  @override
  String get steepWall => 'Mur raide';

  @override
  String get verticalWall => 'Mur vertical';

  @override
  String get caveSection => 'Section grotte';

  @override
  String get roofSection => 'Section toit';

  @override
  String get routeNotFound => 'Voie introuvable';

  @override
  String laneLabel(int number) {
    return 'Couloir $number';
  }

  @override
  String communitySuggested(String grade, int count) {
    return 'Suggéré par la communauté : $grade (moyenne de $count propositions)';
  }

  @override
  String get comments => 'Commentaires';

  @override
  String get gradeProposals => 'Propositions de cotation';

  @override
  String get warnings => 'Avertissements';

  @override
  String get filters => 'Filtres';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get noRoutesFound => 'Aucune voie trouvée';

  @override
  String get adjustFiltersOrAddRoute => 'Essayez d\'ajuster vos filtres ou d\'ajouter une nouvelle voie';

  @override
  String get unknown => 'Inconnu';

  @override
  String get progress => 'Progression';

  @override
  String get track => 'Suivre';

  @override
  String get comment => 'Commentaire';

  @override
  String get proposeGrade => 'Proposer une cotation';

  @override
  String get manageTick => 'Gérer la coche';

  @override
  String get leadSend => 'Enchaînement en tête';

  @override
  String get trackProgress => 'Suivre la progression';

  @override
  String get tickRemoved => 'Coche supprimée';

  @override
  String get addComment => 'Ajouter un commentaire';

  @override
  String get filtersAndSorting => 'Filtres et tri';

  @override
  String get sortBy => 'Trier par';

  @override
  String get basicFilters => 'Filtres de base';

  @override
  String get userInteractions => 'Interactions utilisateur';

  @override
  String get clearAllFilters => 'Effacer tous les filtres';

  @override
  String get sortby => 'Trier par';

  @override
  String get allSections => 'Toutes les sections';

  @override
  String get allGrades => 'Toutes les cotations';

  @override
  String get allLanes => 'Toutes les voies';

  @override
  String get allRouteSetters => 'Tous les ouvreurs';

  @override
  String get tickedRoutes => 'Voies cochées';

  @override
  String get likedRoutes => 'Voies aimées';

  @override
  String get warnedRoutes => 'Voies signalées';

  @override
  String get projectRoutes => 'Voies projet';

  @override
  String get newestFirst => 'Plus récentes d\'abord';

  @override
  String get oldestFirst => 'Plus anciennes d\'abord';

  @override
  String get nameAZ => 'Nom (A-Z)';

  @override
  String get nameZA => 'Nom (Z-A)';

  @override
  String get gradeEasyToHard => 'Cotation (facile à difficile)';

  @override
  String get gradeHardToEasy => 'Cotation (difficile à facile)';

  @override
  String get mostLikes => 'Plus aimées';

  @override
  String get leastLikes => 'Moins aimées';

  @override
  String get mostComments => 'Plus commentées';

  @override
  String get leastComments => 'Moins commentées';

  @override
  String get mostTicks => 'Plus cochées';

  @override
  String get leastTicks => 'Moins cochées';

  @override
  String get filterStateAll => 'Toutes';

  @override
  String get filterStateOnly => 'Seulement';

  @override
  String get filterStateExclude => 'Exclure';

  @override
  String get noPerformanceData => 'Aucune donnée de performance disponible';

  @override
  String get performanceSummary => 'Résumé des Performances';

  @override
  String get trFlash => 'Flash en TR';

  @override
  String get allTimeStats => 'Statistiques de tous les temps';

  @override
  String get totalLikesGiven => 'Total Likes Donnés';

  @override
  String get commentsPosted => 'Commentaires Postés';

  @override
  String get wallSectionsClimbed => 'Sections de Mur Escaladées';

  @override
  String get gradesAchieved => 'Cotations Réussies';

  @override
  String get noGradeData => 'Aucune donnée de cotation disponible';

  @override
  String get completed => 'Terminées';

  @override
  String get flashed => 'Flashées';

  @override
  String get detailedStatistics => 'Statistiques détaillées';

  @override
  String get routesCompleted => 'Voies terminées :';

  @override
  String get flashes => 'Flashs';

  @override
  String get totalAttemptsColon => 'Total tentatives :';

  @override
  String gradeStatistics(String grade) {
    return 'Statistiques $grade';
  }

  @override
  String get added => 'Ajouté';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int count) {
    return 'Il y a $count jours';
  }

  @override
  String get weekAgo => 'Il y a 1 semaine';

  @override
  String weeksAgo(int count) {
    return 'Il y a $count semaines';
  }

  @override
  String get monthAgo => 'Il y a 1 mois';

  @override
  String monthsAgo(int count) {
    return 'Il y a $count mois';
  }

  @override
  String get report => 'Signaler';

  @override
  String get propose => 'Proposer';
}
