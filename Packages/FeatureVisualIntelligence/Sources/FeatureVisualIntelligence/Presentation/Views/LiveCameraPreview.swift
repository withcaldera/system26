import AVFoundation
import Core
import SwiftUI

#if os(iOS)
  struct LiveCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewView {
      let view = PreviewView()
      view.backgroundColor = .black
      view.videoPreviewLayer.session = CameraService.shared.session
      view.videoPreviewLayer.videoGravity = .resizeAspectFill
      if let connection = view.videoPreviewLayer.connection {
        if #available(iOS 17.0, *) {
          connection.videoRotationAngle = 0
        } else {
          connection.videoOrientation = .portrait
        }
      }
      return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
      //
    }

    class PreviewView: UIView {
      override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
      }

      var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
          fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check `layerClass` implementation.")
        }
        return layer
      }
    }
  }
#elseif os(visionOS)
  struct LiveCameraPreview: View {
    var body: some View {
      ZStack {
        Color.black
        VStack(spacing: 8) {
          Image(systemName: "camera.fill")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
          Text(Localization.string("LIVE_CAMERA_PREVIEW_UNAVAILABLE"))
            .multilineTextAlignment(.center)
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding()
      }
    }
  }
#else
  import AppKit

  struct LiveCameraPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
      let view = NSView(frame: .zero)
      view.wantsLayer = true

      let previewLayer = AVCaptureVideoPreviewLayer(session: CameraService.shared.session)
      previewLayer.videoGravity = .resizeAspectFill
      previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

      view.layer = previewLayer

      return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
      if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
        layer.frame = nsView.bounds
        if let connection = layer.connection, connection.isVideoMirroringSupported {
          connection.automaticallyAdjustsVideoMirroring = false
          connection.isVideoMirrored = false
        }
      }
    }
  }
#endif
