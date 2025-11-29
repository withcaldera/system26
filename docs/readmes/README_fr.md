# `System26`

System26 est un utilitaire natif pensé pour explorer le framework `SystemLanguageModel` directement sur l'appareil Apple. Il affiche des métriques de performance en temps réel pour les modèles de fondation locaux dans l'écosystème Apple.

## Objectif

L'application aide les développeurs et passionnés à comprendre le comportement de l'inférence locale sur Apple Silicon, sans dépendre d'une connexion cloud.

## Plateformes Prises en Charge

*   **macOS :** Optimisé pour les flux de travail de bureau.
*   **iOS (iPhone) :** Interface mobile entièrement réactive.
*   **iPadOS :** Prend en charge la vue partagée et les mises en page grand écran.

## Fonctionnalités

*   **Vue des performances en temps réel :**
    *   **Débit :** Mesure la vitesse de génération en Tokens Par Seconde (TPS).
    *   **Latence :** Suit le Temps pour le Premier Token (TTFT) avec une précision à la milliseconde.
    *   **Mémoire :** Surveille l'utilisation de la mémoire résidente pendant l'inférence.
    *   **Thermique :** Signale l'état thermique de l'appareil (Nominal, Moyen, Sérieux, Critique).
*   **Modes prêts à l'emploi :**
    *   **Usage Général :** Génération de texte standard.
    *   **Étiquetage de Contenu :** Tâches spécialisées d'extraction et de classification.
    *   **Outils d'Écriture :** Simulation de relecture et d'édition.
    *   **Résumé :** Tests de condensation de texte.
    *   **Traduction en Direct :** Performance de traduction linguistique en temps réel.
*   **Personnalisation :** Instructions système et invites entièrement modifiables pour tester divers comportements de modèle.
*   **Localisation :** Entièrement localisé en 10 langues (Anglais, Chinois, Espagnol, Français, Portugais, Allemand, Italien, Japonais, Coréen, Vietnamien).

## Prérequis

*   **Système d'Exploitation :** macOS 26 (Tahoe), iOS 26, iPadOS 26, visionOS 26 ou version ultérieure.
*   **Matériel :** Appareil avec Apple Neural Engine (puces Apple Silicon série M ou série A).
*   **Développement :** Xcode 26+ requis pour la compilation.

## Comment Exécuter

1.  Ouvrez `System26.xcodeproj` dans Xcode.
2.  Sélectionnez votre appareil cible (Mac, iPhone ou iPad).
3.  Compilez et Exécutez (Cmd + R).
