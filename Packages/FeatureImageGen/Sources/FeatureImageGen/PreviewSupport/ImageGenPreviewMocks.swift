#if DEBUG
  import CoreGraphics
  import Foundation
  import SwiftUI
  #if canImport(ImagePlayground)
    import ImagePlayground

    private func decodeStyle(named name: String) -> ImagePlaygroundStyle? {
      let data = Data("\"\(name)\"".utf8)
      return try? JSONDecoder().decode(ImagePlaygroundStyle.self, from: data)
    }
  #endif

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  final class MockImageGenService: ImageGenServiceProtocol {
    func generateImages(request: GenerationRequest) -> AsyncThrowingStream<(CGImage, Int), Error> {
      let first = Self.makeImage(color: CGColor(red: 0.15, green: 0.6, blue: 0.95, alpha: 1))
      let second = Self.makeImage(color: CGColor(red: 0.95, green: 0.55, blue: 0.3, alpha: 1))

      return AsyncThrowingStream { continuation in
        continuation.yield((first, 1))
        continuation.yield((second, 2))
        continuation.finish()
      }
    }

    func generateConcepts(for theme: String) -> AsyncThrowingStream<([String], [String]), Error> {
      AsyncThrowingStream { continuation in
        continuation.yield(
          (
            ["neon skyline", "glass towers", "flying cars"],
            ["rain-soaked streets", "purple dusk", "chrome reflections"]
          ))
        continuation.finish()
      }
    }

    func generateRandomSeed() -> AsyncThrowingStream<String, Error> {
      AsyncThrowingStream { continuation in
        continuation.yield("Futuristic coastal city at night")
        continuation.finish()
      }
    }

    func availableStyles() async throws -> [ImagePlaygroundStyle] {
      #if canImport(ImagePlayground)
        return [decodeStyle(named: "illustration"), decodeStyle(named: "sketch")].compactMap { $0 }
      #else
        return [ImagePlaygroundStyle(id: "illustration"), ImagePlaygroundStyle(id: "sketch")]
      #endif
    }

    static func makeImage(color: CGColor, size: CGSize = CGSize(width: 320, height: 200)) -> CGImage {
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
      guard
        let context = CGContext(
          data: nil,
          width: Int(size.width),
          height: Int(size.height),
          bitsPerComponent: 8,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: bitmapInfo
        )
      else {
        return CGImage.makePlaceholder()
      }

      context.setFillColor(color)
      context.fill(CGRect(origin: .zero, size: size))

      return context.makeImage() ?? CGImage.makePlaceholder()
    }
  }

  extension CGImage {
    private static func makePlaceholder(size: CGSize = CGSize(width: 8, height: 8)) -> CGImage {
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue
      guard
        let context = CGContext(
          data: nil,
          width: Int(size.width),
          height: Int(size.height),
          bitsPerComponent: 8,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: bitmapInfo
        )
      else {
        return makeFallbackPixel(colorSpace: colorSpace, bitmapInfo: bitmapInfo)
      }

      context.setFillColor(CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
      context.fill(CGRect(origin: .zero, size: size))

      if let image = context.makeImage() {
        return image
      }

      return makeFallbackPixel(colorSpace: colorSpace, bitmapInfo: bitmapInfo)
    }

    private static func makeFallbackPixel(colorSpace: CGColorSpace, bitmapInfo: UInt32) -> CGImage {
      let pixel: [UInt8] = [0, 0, 0, 255]
      guard
        let provider = CGDataProvider(data: Data(pixel) as CFData),
        let image = CGImage(
          width: 1,
          height: 1,
          bitsPerComponent: 8,
          bitsPerPixel: 32,
          bytesPerRow: 4,
          space: colorSpace,
          bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
          provider: provider,
          decode: nil,
          shouldInterpolate: true,
          intent: .defaultIntent
        )
      else {
        preconditionFailure("Unable to create fallback pixel image.")
      }

      return image
    }
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  extension ImageGenViewModel {
    public static var preview: ImageGenViewModel {
      let service = MockImageGenService()
      let vm = ImageGenViewModel(service: service)
      vm.themeInput = "Futuristic seaside arcade"
      vm.textConcepts = ["neon boardwalk", "glass ocean", "moonlit surf"]
      vm.suggestedConcepts = ["pink fog", "chrome railing"]

      #if canImport(ImagePlayground)
        let styles: [ImagePlaygroundStyle] = [
          decodeStyle(named: "illustration"),
          decodeStyle(named: "sketch")
        ].compactMap { $0 }
      #else
        let styles = [ImagePlaygroundStyle(id: "illustration"), ImagePlaygroundStyle(id: "sketch")]
      #endif
      vm.availableStyles = styles
      vm.selectedStyle = styles.first
      vm.requestedImageLimit = 2

      let sampleImage = MockImageGenService.makeImage(color: CGColor(red: 0.1, green: 0.7, blue: 0.5, alpha: 1))
      let rendered = Image(decorative: sampleImage, scale: 1.0, orientation: .up)
      vm.partialImage = rendered
      vm.streamedImages = [rendered]
      vm.lastResult = ImageGenResult(
        prompt: vm.textConcepts.joined(separator: ", "),
        styleName: vm.selectedStyle?.displayName ?? "Illustration",
        totalGenerationTime: 2.8,
        generatedCGImage: sampleImage
      )
      vm.progress = "Complete in 2.8 s"

      return vm
    }
  }
#endif
