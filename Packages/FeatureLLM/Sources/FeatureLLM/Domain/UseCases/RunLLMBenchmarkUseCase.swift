import Core
import Foundation
import MachO
import NaturalLanguage

public struct BenchmarkState: Sendable {
  public var responseText: String = ""
  public var tokensPerSecond: Double = 0.0
  public var timeToFirstToken: Double = 0.0
  public var memoryUsage: String = "0.0"
  public var isGenerating: Bool = false
  public var tokenCount: Int = 0

  public init() {}
}

public enum BenchmarkEvent: Sendable {
  case started
  case progress(text: String, tokenCount: Int, tps: Double, timeToFirstToken: Double)
  case memory(String)
  case finished
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public protocol RunLLMBenchmarkUseCaseProtocol: Sendable {
  func execute(model: ModelType, prompt: String, systemPrompt: String) -> AsyncThrowingStream<
    BenchmarkEvent, Error
  >
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public final class RunLLMBenchmarkUseCase: RunLLMBenchmarkUseCaseProtocol {
  private let service: LLMServiceProtocol

  public init(service: LLMServiceProtocol) {
    self.service = service
  }

  public func execute(model: ModelType, prompt: String, systemPrompt: String)
    -> AsyncThrowingStream<BenchmarkEvent, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        continuation.yield(.started)
        let startTime = Date()
        var firstTokenDate: Date?

        let memoryTask = Task {
          while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 500_000_000)
            let usage = self.getMemoryUsage()
            continuation.yield(.memory(usage))
          }
        }

        do {
          let stream = service.streamResponse(
            for: model, prompt: prompt, systemPrompt: systemPrompt)

          for try await text in stream {
            if firstTokenDate == nil {
              firstTokenDate = Date()
            }

            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            let wordCount = tokenizer.tokens(for: text.startIndex..<text.endIndex).count

            let hasCJK = text.unicodeScalars.contains {
              $0.value >= 0x4E00 && $0.value <= 0x9FFF
            }

            var tokenCount = 0
            if hasCJK {
              tokenCount = Int(Double(text.count) * 0.6)
            } else {
              if wordCount > 0 {
                tokenCount = Int(Double(wordCount) * 1.33)
              } else {
                tokenCount = Int(Double(text.count) / 4.0)
              }
            }

            var tps = 0.0
            var ttft = 0.0

            if let start = firstTokenDate {
              ttft = start.timeIntervalSince(startTime)
              let timeSinceFirst = Date().timeIntervalSince(start)
              if timeSinceFirst > 0 {
                tps = Double(tokenCount) / timeSinceFirst
              }
            }

            continuation.yield(
              .progress(text: text, tokenCount: tokenCount, tps: tps, timeToFirstToken: ttft))
          }

          memoryTask.cancel()
          continuation.yield(.finished)
          continuation.finish()
        } catch {
          memoryTask.cancel()
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }
  }

  private func getMemoryUsage() -> String {
    var taskInfo = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
      }
    }

    guard kerr == KERN_SUCCESS else {
      return Localization.string("NOT_AVAILABLE")
    }
    let memoryUsageMB = Double(taskInfo.resident_size) / (1024 * 1024)
    return String(format: "%.1f", memoryUsageMB)
  }
}
