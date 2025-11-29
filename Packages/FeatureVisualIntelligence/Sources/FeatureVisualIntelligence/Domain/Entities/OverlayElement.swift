import Foundation
import SwiftUI

public enum OverlayElement: Sendable, Identifiable {
  case boundingBox(id: UUID, rect: CGRect, label: String, color: Color)
  case textBubble(id: UUID, rect: CGRect, text: String)
  case skeleton(id: UUID, joints: [CGPoint], connections: [[CGPoint]])

  public var id: UUID {
    switch self {
    case .boundingBox(let id, _, _, _):
      return id

    case .textBubble(let id, _, _):
      return id

    case .skeleton(let id, _, _):
      return id
    }
  }
}
