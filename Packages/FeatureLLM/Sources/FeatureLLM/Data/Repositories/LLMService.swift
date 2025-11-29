import Core
import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public final class LLMService: LLMServiceProtocol {
  public init() {}

  public func isModelAvailable(_ model: ModelType) -> Bool {
    model.systemModel.isAvailable
  }

  public func streamResponse(
    for modelType: ModelType,
    prompt: String,
    systemPrompt: String
  ) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        do {
          let model = modelType.systemModel
          guard model.isAvailable else {
            throw NSError(
              domain: "Benchmark",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: Localization.string("MODEL_NOT_AVAILABLE")]
            )
          }

          let session = LanguageModelSession(model: model, instructions: systemPrompt)
          let stream = session.streamResponse(to: prompt)

          for try await partialResponse in stream {
            let rawText = "\(partialResponse)"
            let cleanText = self.cleanResponse(rawText)
            continuation.yield(cleanText)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { @Sendable _ in
        task.cancel()
      }
    }
  }

  private func cleanResponse(_ text: String) -> String {
    var cleanText = text

    if let rangeStart = cleanText.range(of: "Snapshot(content: \"") {
      if let rangeEnd = cleanText.range(
        of: "\", rawContent:", range: rangeStart.upperBound..<cleanText.endIndex) {
        cleanText = String(cleanText[rangeStart.upperBound..<rangeEnd.lowerBound])
      } else if cleanText.hasSuffix("\")") {
        let endIndex = cleanText.index(cleanText.endIndex, offsetBy: -2)
        if endIndex > rangeStart.upperBound {
          cleanText = String(cleanText[rangeStart.upperBound..<endIndex])
        }
      } else if let rangeEnd = cleanText.range(of: "\"", options: .backwards) {
        if rangeEnd.lowerBound > rangeStart.upperBound {
          cleanText = String(cleanText[rangeStart.upperBound..<rangeEnd.lowerBound])
        }
      }
    }

    cleanText = cleanText.replacingOccurrences(of: "\\n", with: "\n")
    cleanText = cleanText.replacingOccurrences(of: "\\\"", with: "\"")
    return cleanText
  }
}
