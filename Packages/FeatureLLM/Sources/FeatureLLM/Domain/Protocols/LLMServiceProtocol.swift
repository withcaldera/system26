import Core
import Foundation

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public protocol LLMServiceProtocol: Sendable {
  func streamResponse(for model: ModelType, prompt: String, systemPrompt: String)
    -> AsyncThrowingStream<String, Error>
  func isModelAvailable(_ model: ModelType) -> Bool
}
