# `System26`

System26 è un'utility nativa pensata per provare il framework `SystemLanguageModel` direttamente sul dispositivo Apple. Mostra metriche di prestazioni in tempo reale per i Foundation Models locali in tutto l'ecosistema Apple.

## Scopo

L'applicazione aiuta sviluppatori e appassionati a capire come si comporta l'inferenza sul dispositivo su Apple Silicon, senza doversi affidare alla connettività cloud.

## Piattaforme Supportate

*   **macOS:** Ottimizzato per i flussi di lavoro desktop.
*   **iOS (iPhone):** Interfaccia mobile completamente reattiva.
*   **iPadOS:** Supporta la visualizzazione divisa e i layout a grande schermo.

## Caratteristiche

*   **Vista prestazioni in tempo reale:**
    *   **Throughput:** Misura la velocità di generazione in Token Per Secondo (TPS).
    *   **Latenza:** Traccia il Tempo al Primo Token (TTFT) con precisione al millisecondo.
    *   **Memoria:** Monitora l'utilizzo della memoria residente durante l'inferenza.
    *   **Termico:** Segnala lo stato termico del dispositivo (Nominale, Discreto, Serio, Critico).
*   **Modalità predefinite:**
    *   **Scopo Generale:** Generazione di testo standard.
    *   **Tagging Contenuto:** Compiti specializzati di estrazione e classificazione.
    *   **Strumenti di Scrittura:** Simulazione di correzione bozze e modifica.
    *   **Riepilogo:** Test di condensazione del testo.
    *   **Traduzione dal Vivo:** Prestazioni di traduzione linguistica in tempo reale.
*   **Personalizzazione:** Istruzioni di sistema e prompt completamente modificabili per testare vari comportamenti del modello.
*   **Localizzazione:** Completamente localizzato in 10 lingue (Inglese, Cinese, Spagnolo, Francese, Portoghese, Tedesco, Italiano, Giapponese, Coreano, Vietnamita).

## Prerequisiti

*   **Sistema Operativo:** macOS 26 (Tahoe), iOS 26, iPadOS 26, visionOS 26 o successivo.
*   **Hardware:** Dispositivo con Apple Neural Engine (chip Apple Silicon Serie M o Serie A).
*   **Sviluppo:** Xcode 26+ richiesto per la compilazione.

## Come Eseguire

1.  Apri `System26.xcodeproj` in Xcode.
2.  Seleziona il tuo dispositivo di destinazione (Mac, iPhone o iPad).
3.  Compila ed Esegui (Cmd + R).
