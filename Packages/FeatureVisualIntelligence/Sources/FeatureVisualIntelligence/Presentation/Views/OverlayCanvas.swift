import SwiftUI

struct OverlayCanvas: View {
  let elements: [OverlayElement]
  let thermalScore: Double
  let startTime: Date
  let frameSize: CGSize

  var body: some View {
    GeometryReader { _ in
      Canvas { context, size in
        // swiftlint:disable pattern_matching_keywords
        for element in elements {
          switch element {
          case .boundingBox(_, let normalizedRect, let label, let color):
            let rect = project(normalizedRect: normalizedRect, viewSize: size)

            let path = Path(roundedRect: rect, cornerRadius: 8)
            context.stroke(path, with: .color(color), lineWidth: 3)

            let labelRect = CGRect(x: rect.minX, y: rect.minY - 24, width: 100, height: 24)
            context.fill(
              Path(roundedRect: labelRect, cornerRadius: 4), with: .color(color.opacity(0.8)))

            context.draw(Text(label).font(.caption).bold().foregroundColor(.white), in: labelRect)

          case .textBubble(_, let normalizedRect, let text):
            let rect = project(normalizedRect: normalizedRect, viewSize: size)

            let path = Path(roundedRect: rect, cornerRadius: 4)
            context.stroke(path, with: .color(.yellow), lineWidth: 2)
            context.fill(path, with: .color(.yellow.opacity(0.2)))

            context.draw(Text(text).font(.caption).foregroundColor(.yellow), in: rect)

          case .skeleton(_, let normalizedJoints, _):
            let joints = normalizedJoints.map { project(normalizedPoint: $0, viewSize: size) }

            for point in joints {
              let circle = Path(
                ellipseIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
              context.fill(circle, with: .color(.green))
            }

            if joints.count > 1 {
              var path = Path()
              path.move(to: joints[0])
              for i in 1..<joints.count {
                path.addLine(to: joints[i])
              }
              context.stroke(path, with: .color(.green), lineWidth: 2)
            }
          }
        }
        // swiftlint:enable pattern_matching_keywords
      }
      .drawingGroup()
      .opacity(thermalScore > 90 ? 0.5 : 1.0)
    }
  }

  // MARK: - Projection Logic

  func project(normalizedRect: CGRect, viewSize: CGSize) -> CGRect {
    let (renderedWidth, renderedHeight, offsetX, offsetY) = calculateDimensions(viewSize: viewSize)

    let x = normalizedRect.minX * renderedWidth + offsetX
    let y = normalizedRect.minY * renderedHeight + offsetY
    let width = normalizedRect.width * renderedWidth
    let height = normalizedRect.height * renderedHeight

    return CGRect(x: x, y: y, width: width, height: height)
  }

  func project(normalizedPoint: CGPoint, viewSize: CGSize) -> CGPoint {
    let (renderedWidth, renderedHeight, offsetX, offsetY) = calculateDimensions(viewSize: viewSize)

    let x = normalizedPoint.x * renderedWidth + offsetX
    let y = normalizedPoint.y * renderedHeight + offsetY

    return CGPoint(x: x, y: y)
  }

  func calculateDimensions(viewSize: CGSize) -> (w: CGFloat, h: CGFloat, ox: CGFloat, oy: CGFloat) {
    let viewAspectRatio = viewSize.width / viewSize.height

    let imageAspectRatio: CGFloat
    if frameSize.width > 0 && frameSize.height > 0 {
      imageAspectRatio = frameSize.width / frameSize.height
    } else {
      imageAspectRatio = 9.0 / 16.0
    }

    let renderedWidth: CGFloat
    let renderedHeight: CGFloat

    if viewAspectRatio < imageAspectRatio {
      renderedHeight = viewSize.height
      renderedWidth = renderedHeight * imageAspectRatio
    } else {
      renderedWidth = viewSize.width
      renderedHeight = renderedWidth / imageAspectRatio
    }

    let offsetX = (viewSize.width - renderedWidth) / 2.0
    let offsetY = (viewSize.height - renderedHeight) / 2.0

    return (renderedWidth, renderedHeight, offsetX, offsetY)
  }
}

#if DEBUG
  #Preview("Overlay Canvas") {
    let overlays: [OverlayElement] = [
      .boundingBox(
        id: UUID(),
        rect: CGRect(x: 0.15, y: 0.2, width: 0.35, height: 0.5),
        label: "Person",
        color: .green
      ),
      .textBubble(
        id: UUID(),
        rect: CGRect(x: 0.55, y: 0.15, width: 0.25, height: 0.12),
        text: "26 FPS"
      ),
      .skeleton(
        id: UUID(),
        joints: [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.25, y: 0.35), CGPoint(x: 0.3, y: 0.5)],
        connections: []
      )
    ]

    return OverlayCanvas(
      elements: overlays,
      thermalScore: 42,
      startTime: Date(),
      frameSize: CGSize(width: 1920, height: 1080)
    )
    .frame(height: 300)
    .background(.black)
  }
#endif
