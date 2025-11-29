import Core
import Foundation
import Observation

@MainActor
@Observable
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public final class LLMDashboardViewModel {
  public var state = BenchmarkState()
  public var selectedModel: ModelType = .general {
    didSet {
      if state.isGenerating {
        abortBenchmark()
      }
      resetMetrics()
      errorMessage = nil
      updatePromptsForModel()
    }
  }
  public var prompt: String = ""
  public var systemPrompt: String = ""
  public var errorMessage: String?

  public var isSystemPromptEnabled: Bool {
    selectedModel != .contentTagging
  }

  private let runBenchmarkUseCase: RunLLMBenchmarkUseCaseProtocol
  private var currentTask: Task<Void, Never>?

  public init(runBenchmarkUseCase: RunLLMBenchmarkUseCaseProtocol) {
    self.runBenchmarkUseCase = runBenchmarkUseCase
    updatePromptsForModel()
  }

  public func runBenchmark() {
    resetMetrics()
    errorMessage = nil

    let currentModelType = selectedModel
    let finalPrompt = prompt
    let finalSystemPrompt = systemPrompt

    guard !finalPrompt.isEmpty else {
      return
    }

    currentTask = Task {
      do {
        let stream = runBenchmarkUseCase.execute(
          model: currentModelType, prompt: finalPrompt, systemPrompt: finalSystemPrompt)

        // swiftlint:disable pattern_matching_keywords
        for try await event in stream {
          switch event {
          case .started:
            self.state.isGenerating = true

          case .progress(let text, let count, let tps, let ttft):
            self.state.responseText = text
            self.state.tokenCount = count
            self.state.tokensPerSecond = tps
            self.state.timeToFirstToken = ttft

          case .memory(let usage):
            self.state.memoryUsage = usage

          case .finished:
            self.state.isGenerating = false
          }
        }
        // swiftlint:enable pattern_matching_keywords
      } catch {
        if !Task.isCancelled {
          self.errorMessage = error.localizedDescription
          self.state.isGenerating = false
        }
      }
    }
  }

  public func abortBenchmark() {
    currentTask?.cancel()
    currentTask = nil
    state.isGenerating = false
  }

  private func resetMetrics() {
    state = BenchmarkState()
  }

  private func updatePromptsForModel() {
    switch selectedModel {
    case .general:
      if let defaultSample = Localization.generalPrompts.first(where: {
        $0.language == Localization.currentLanguage
      }) {
        self.prompt = defaultSample.text
      } else if let fallback = Localization.generalPrompts.first {
        self.prompt = fallback.text
      }
      self.systemPrompt = Localization.defaultSystemPrompt

    case .contentTagging:
      self.prompt = Localization.string("DEFAULT_PROMPT_TAGGING")
      self.systemPrompt = Localization.string("SYSTEM_PROMPT_DISABLED_NOTICE")
    }
  }
}
