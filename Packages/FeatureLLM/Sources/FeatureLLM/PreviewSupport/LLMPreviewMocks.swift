#if DEBUG
  import Core
  import SwiftUI

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  final class MockRunLLMBenchmarkUseCase: RunLLMBenchmarkUseCaseProtocol {
    func execute(model: ModelType, prompt: String, systemPrompt: String) -> AsyncThrowingStream<
      BenchmarkEvent, Error
    > {
      AsyncThrowingStream { continuation in
        continuation.yield(.started)
        continuation.yield(
          .progress(
            text: "The Neural Engine handled this prompt with ease.",
            tokenCount: 96,
            tps: 45.2,
            timeToFirstToken: 120
          ))
        continuation.yield(.memory("612.4"))
        continuation.yield(.finished)
        continuation.finish()
      }
    }
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  extension LLMDashboardViewModel {
    public static var preview: LLMDashboardViewModel {
      let vm = LLMDashboardViewModel(runBenchmarkUseCase: MockRunLLMBenchmarkUseCase())
      vm.selectedModel = .general
      vm.prompt = "Tell me about on-device AI performance."
      vm.systemPrompt = "You are a concise benchmark assistant."
      vm.state.tokensPerSecond = 45.2
      vm.state.tokenCount = 128
      vm.state.timeToFirstToken = 120
      vm.state.memoryUsage = "612.4"
      vm.state.responseText = "Apple Silicon delivers smooth interactive decoding with low latency."
      return vm
    }
  }
#endif
