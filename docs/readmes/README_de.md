# `System26`

System26 ist ein natives Dienstprogramm, mit dem du das geräteinterne `SystemLanguageModel`-Framework von Apple ausprobieren kannst. Es zeigt Echtzeit-Leistungswerte für lokale Foundation Models im gesamten Apple-Ökosystem.

## Zweck

Die Anwendung hilft Entwicklern und Enthusiasten zu sehen, wie sich On-Device-KI auf Apple Silicon verhält – ohne Cloud-Verbindung oder Laborausrüstung.

## Unterstützte Plattformen

*   **macOS:** Optimiert für Desktop-Workflows.
*   **iOS (iPhone):** Vollständig responsive mobile Benutzeroberfläche.
*   **iPadOS:** Unterstützt Split-View und Großbildschirm-Layouts.

## Funktionen

*   **Echtzeit-Leistungsansicht:**
    *   **Durchsatz:** Zeigt die Generierungsgeschwindigkeit in Token pro Sekunde (TPS).
    *   **Latenz:** Verfolgt die Zeit bis zum ersten Token (TTFT) mit Millisekundengenauigkeit.
    *   **Speicher:** Überwacht die Nutzung des residenten Speichers während der Inferenz.
    *   **Thermisch:** Meldet den thermischen Zustand des Geräts (Nominal, Fair, Ernst, Kritisch).
*   **Modus-Voreinstellungen:**
    *   **Allgemeiner Zweck:** Standard-Textgenerierung.
    *   **Inhaltskennzeichnung:** Spezialisierte Extraktions- und Klassifizierungsaufgaben.
    *   **Schreibwerkzeuge:** Korrekturlesen und Bearbeitungssimulation.
    *   **Zusammenfassung:** Textkondensationstests.
    *   **Live-Übersetzung:** Echtzeit-Sprachübersetzungsleistung.
*   **Anpassung:** Vollständig bearbeitbare Systemanweisungen und Eingabeaufforderungen, um verschiedene Modellverhalten zu testen.
*   **Lokalisierung:** Vollständig lokalisiert in 10 Sprachen (Englisch, Chinesisch, Spanisch, Französisch, Portugiesisch, Deutsch, Italienisch, Japanisch, Koreanisch, Vietnamesisch).

## Voraussetzungen

*   **Betriebssystem:** macOS 26 (Tahoe), iOS 26, iPadOS 26, visionOS 26 oder höher.
*   **Hardware:** Gerät mit Apple Neural Engine (Apple Silicon M-Serie oder A-Serie Chips).
*   **Entwicklung:** Xcode 26+ zum Erstellen erforderlich.

## Ausführung

1.  Öffnen Sie `System26.xcodeproj` in Xcode.
2.  Wählen Sie Ihr Zielgerät (Mac, iPhone oder iPad).
3.  Erstellen und Ausführen (Cmd + R).
