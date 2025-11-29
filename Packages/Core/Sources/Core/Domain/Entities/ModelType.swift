import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public enum ModelType: String, CaseIterable, Identifiable, Sendable {
  case general = "General Purpose"
  case contentTagging = "Content Tagging"

  public var id: String { self.rawValue }

  public var localizedName: String {
    Localization.string(localizationKey)
  }

  private var localizationKey: String {
    switch self {
    case .general:
      return "MODEL_GENERAL_PURPOSE"

    case .contentTagging:
      return "MODEL_CONTENT_TAGGING"
    }
  }

  public var iconName: String {
    switch self {
    case .general:
      return "sparkles"

    case .contentTagging:
      return "tag.fill"
    }
  }

  public var systemModel: SystemLanguageModel {
    switch self {
    case .general:
      return SystemLanguageModel.default

    case .contentTagging:
      return SystemLanguageModel(useCase: .contentTagging)
    }
  }
}
