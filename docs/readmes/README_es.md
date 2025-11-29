# `System26`

System26 es una utilidad nativa pensada para probar el marco `SystemLanguageModel` directamente en el dispositivo de Apple. Muestra métricas de rendimiento en tiempo real para Modelos Fundamentales locales en todo el ecosistema de Apple.

## Propósito

La aplicación ayuda a desarrolladores y entusiastas a ver cómo se comporta la inferencia en el dispositivo sobre Apple Silicon sin depender de la conectividad en la nube.

## Plataformas Compatibles

*   **macOS:** Optimizado para flujos de trabajo de escritorio.
*   **iOS (iPhone):** Interfaz móvil totalmente receptiva.
*   **iPadOS:** Soporta pantalla dividida y diseños de pantalla grande.

## Características

*   **Vista de rendimiento en tiempo real:**
    *   **Rendimiento:** Mide la velocidad de generación en Tokens Por Segundo (TPS).
    *   **Latencia:** Rastrea el Tiempo al Primer Token (TTFT) con precisión de milisegundos.
    *   **Memoria:** Monitorea el uso de memoria residente durante la inferencia.
    *   **Térmico:** Informa el estado térmico del dispositivo (Nominal, Justo, Serio, Crítico).
*   **Modos preconfigurados:**
    *   **Propósito General:** Generación de texto estándar.
    *   **Etiquetado de Contenido:** Tareas especializadas de extracción y clasificación.
    *   **Herramientas de Escritura:** Simulación de corrección y edición.
    *   **Resumen:** Pruebas de condensación de texto.
    *   **Traducción en Vivo:** Rendimiento de traducción de idiomas en tiempo real.
*   **Personalización:** Instrucciones del sistema y avisos totalmente editables para probar diversos comportamientos del modelo.
*   **Localización:** Totalmente localizado en 10 idiomas (Inglés, Chino, Español, Francés, Portugués, Alemán, Italiano, Japonés, Coreano, Vietnamita).

## Requisitos Previos

*   **Sistema Operativo:** macOS 26 (Tahoe), iOS 26, iPadOS 26, visionOS 26 o posterior.
*   **Hardware:** Dispositivo con Apple Neural Engine (chips Apple Silicon Serie M o Serie A).
*   **Desarrollo:** Se requiere Xcode 26+ para compilar.

## Cómo Ejecutar

1.  Abre `System26.xcodeproj` en Xcode.
2.  Selecciona tu dispositivo de destino (Mac, iPhone o iPad).
3.  Compila y Ejecuta (Cmd + R).
