import Core
import Foundation

#if canImport(ImagePlayground)
  import ImagePlayground

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  extension ImagePlaygroundStyle {
    public var id: String { String(describing: self) }

    public var displayName: String {
      var name = String(describing: self)

      if let range = name.range(of: "Id: \"") ?? name.range(of: "id: \"") {
        let substring = name[range.upperBound...]
        if let endRange = substring.range(of: "\"") {
          name = String(substring[..<endRange.lowerBound])
        }
      }

      let key = name.lowercased()
      switch key {
      case "illustration":
        return Localization.string("IMAGE_STYLE_ILLUSTRATION")

      case "animation":
        return Localization.string("IMAGE_STYLE_ANIMATION")

      case "sketch":
        return Localization.string("IMAGE_STYLE_SKETCH")

      case "messages-background":
        return Localization.string("IMAGE_STYLE_MESSAGES_BACKGROUND")

      default:
        return name.capitalized
      }
    }
  }
#else
  extension ImagePlaygroundStyle {
    public var id: String { String(describing: self) }
    public var displayName: String { String(describing: self).capitalized }
  }
#endif
