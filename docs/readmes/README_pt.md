# `System26`

O System26 é um utilitário nativo para experimentar o framework `SystemLanguageModel` diretamente no dispositivo da Apple. Ele mostra métricas de desempenho em tempo real para Modelos Fundamentais locais em todo o ecossistema da Apple.

## Objetivo

O aplicativo ajuda desenvolvedores e entusiastas a ver como a inferência local se comporta no Apple Silicon, sem depender de conectividade com a nuvem.

## Plataformas Suportadas

*   **macOS:** Otimizado para fluxos de trabalho de desktop.
*   **iOS (iPhone):** Interface móvel totalmente responsiva.
*   **iPadOS:** Suporta visualização dividida e layouts de tela grande.

## Recursos

*   **Visão de desempenho em tempo real:**
    *   **Throughput:** Mede a velocidade de geração em Tokens Por Segundo (TPS).
    *   **Latência:** Rastreia o Tempo para o Primeiro Token (TTFT) com precisão de milissegundos.
    *   **Memória:** Monitora o uso de memória residente durante a inferência.
    *   **Térmico:** Relata o estado térmico do dispositivo (Nominal, Razoável, Sério, Crítico).
*   **Modos pré-ajustados:**
    *   **Uso Geral:** Geração de texto padrão.
    *   **Etiquetagem de Conteúdo:** Tarefas especializadas de extração e classificação.
    *   **Ferramentas de Escrita:** Simulação de revisão e edição.
    *   **Resumo:** Testes de condensação de texto.
    *   **Tradução ao Vivo:** Desempenho de tradução de idiomas em tempo real.
*   **Personalização:** Instruções do sistema e prompts totalmente editáveis para testar vários comportamentos do modelo.
*   **Localização:** Totalmente localizado em 10 idiomas (Inglês, Chinês, Espanhol, Francês, Português, Alemão, Italiano, Japonês, Coreano, Vietnamita).

## Pré-requisitos

*   **Sistema Operacional:** macOS 26 (Tahoe), iOS 26, iPadOS 26, visionOS 26 ou posterior.
*   **Hardware:** Dispositivo com Apple Neural Engine (chips Apple Silicon Série M ou Série A).
*   **Desenvolvimento:** Xcode 26+ necessário para compilar.

## Como Executar

1.  Abra `System26.xcodeproj` no Xcode.
2.  Selecione seu dispositivo de destino (Mac, iPhone ou iPad).
3.  Compile e Execute (Cmd + R).
