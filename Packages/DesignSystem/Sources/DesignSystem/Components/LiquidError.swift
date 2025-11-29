import Core
import SwiftUI

public struct LiquidError: Identifiable, Equatable, Sendable {
  public let id = UUID()
  public let title: String
  public let message: String
  public let suggestion: String?

  public init(title: String, message: String, suggestion: String?) {
    self.title = title
    self.message = message
    self.suggestion = suggestion
  }

  public static func == (lhs: LiquidError, rhs: LiquidError) -> Bool {
    lhs.id == rhs.id
  }
}

public struct LiquidErrorPresenter: ViewModifier {
  @Binding var error: LiquidError?
  @State private var isDetailPresented = false
  @Namespace private var namespace

  public init(error: Binding<LiquidError?>) {
    self._error = error
  }

  public func body(content: Content) -> some View {
    content
      .overlay(alignment: .bottom) {
        if let error = error, !isDetailPresented {
          LiquidErrorBanner(error: error, namespace: namespace) {
            isDetailPresented = true
          }
          .padding()
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .sheet(
        isPresented: $isDetailPresented,
        onDismiss: {
        },
        content: {
          if let error = error {
            NavigationStack {
              LiquidErrorDetailView(error: error, namespace: namespace) {
                isDetailPresented = false
                self.error = nil
              }
            }
            #if os(visionOS)
              .presentationBackground(.regularMaterial)
            #else
              .presentationBackground(.ultraThinMaterial)
            #endif
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
          }
        }
      )
  }
}

struct LiquidErrorBanner: View {
  let error: LiquidError
  let namespace: Namespace.ID
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.title3)
          .foregroundStyle(.red)
          .symbolEffect(.pulse, options: .repeating, isActive: true)

        VStack(alignment: .leading, spacing: 2) {
          Text(error.title)
            .font(.headline)
            .foregroundStyle(.primary)
          Text(error.message)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }

        Spacer()

        Image(systemName: "chevron.right.circle.fill")
          .foregroundStyle(.secondary)
      }
      .padding(12)
      .background {
        #if os(visionOS)
          Capsule()
            .fill(.regularMaterial)
        #else
          Capsule()
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        #endif
      }
      .matchedGeometryEffect(id: "background", in: namespace)
    }
    .buttonStyle(.plain)
  }
}

struct LiquidErrorDetailView: View {
  let error: LiquidError
  let namespace: Namespace.ID
  let dismissAction: () -> Void

  @State private var isCopied = false

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 60))
          .foregroundStyle(.red)
          .symbolEffect(.bounce, options: .nonRepeating, value: true)
          .padding(.top, 40)

        VStack(spacing: 16) {
          Text(error.title)
            .font(.title.weight(.bold))
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)

          ScrollView(.vertical) {
            Text(error.message)
              .font(.custom("Menlo", size: 17, relativeTo: .body))
              .foregroundStyle(.primary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
          }
          .frame(maxHeight: 200)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(.black.opacity(0.1))
          )
          .overlay(alignment: .topTrailing) {
            Button(action: copyToClipboard) {
              Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isCopied ? .green : .secondary)
                .padding(8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(4)
          }
        }
      }
      .padding(24)
    }
    #if !os(macOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(Localization.string("DISMISS"), action: dismissAction)
      }
    }
    .background {
      #if os(visionOS)
        //
      #else
        Rectangle().fill(.clear)
          .matchedGeometryEffect(id: "background", in: namespace, isSource: false)
      #endif
    }
  }

  private func copyToClipboard() {
    let fullText = """
      \(Localization.string("COPY_ERROR_PREFIX")) \(error.title)
      \(Localization.string("COPY_MESSAGE_PREFIX")) \(error.message)
      \(Localization.string("COPY_SUGGESTION_PREFIX")) \(error.suggestion ?? Localization.string("COPY_NONE"))
      """

    #if os(macOS)
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(fullText, forType: .string)
    #else
      UIPasteboard.general.string = fullText
    #endif

    withAnimation {
      isCopied = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      isCopied = false
    }
  }
}

extension View {
  public func liquidErrorPresentation(error: Binding<LiquidError?>) -> some View {
    modifier(LiquidErrorPresenter(error: error))
  }
}

#if DEBUG
  private struct LiquidErrorPreviewContainer: View {
    @State private var error: LiquidError? = LiquidError(
      title: "Streaming Failed",
      message: "The mock model could not produce a response in time.",
      suggestion: "Try a shorter prompt or reduce image size."
    )

    var body: some View {
      VStack(spacing: 16) {
        Text("Tap to toggle error banner")
          .font(.headline)
          .foregroundStyle(.primary)

        Button("Toggle Error") {
          if error == nil {
            error = LiquidError(
              title: "Streaming Failed",
              message: "The mock model could not produce a response in time.",
              suggestion: "Try a shorter prompt or reduce image size."
            )
          } else {
            error = nil
          }
        }
        .buttonStyle(.borderedProminent)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black)
      .liquidErrorPresentation(error: $error)
    }
  }

  #Preview("Liquid Error") {
    LiquidErrorPreviewContainer()
      .preferredColorScheme(.dark)
  }
#endif
