import Core
import DesignSystem
import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

public struct AboutView: View {
  @Environment(\.dismiss)
  var dismiss
  public var isPresentedAsSheet: Bool = false
  @State private var isCopied = false

  public init(isPresentedAsSheet: Bool = false) {
    self.isPresentedAsSheet = isPresentedAsSheet
  }

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }

  private var contactEmail: String {
    "build@withcaldera.com"
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        VStack(spacing: 16) {
          VStack(spacing: 4) {
            Text("System26")
              .font(.custom("Menlo", size: 48).weight(.bold))
              .foregroundStyle(.primary)

            Text("\(Localization.string("VERSION")) \(appVersion)")
              .font(Theme.subheader)
              .foregroundStyle(.secondary)
          }
        }
        .padding(.top, 40)

        VStack(alignment: .leading, spacing: 16) {
          Text(Localization.string("DESCRIPTION_TEXT"))
            .font(Theme.body)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
        }
        .padding(24)
        .liquidSurface()
        .padding(.horizontal, 20)

        VStack(spacing: 16) {
          Link(destination: URL(string: "https://www.withcaldera.com/system26") ?? URL(fileURLWithPath: "")) {
            HStack {
              Label(Localization.string("WEBSITE"), systemImage: "globe")
              Spacer()
              Image(systemName: "arrow.up.right")
                .font(.caption)
            }
            .padding()
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .buttonStyle(.plain)

          Link(destination: URL(string: "https://github.com/withcaldera/system26") ?? URL(fileURLWithPath: "")) {
            HStack {
              Label(
                "GitHub",
                systemImage: "chevron.left.forwardslash.chevron.right")
              Spacer()
              Image(systemName: "arrow.up.right")
                .font(.caption)
            }
            .padding()
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .buttonStyle(.plain)

          Button(
            action: {
              #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(contactEmail, forType: .string)
              #else
                UIPasteboard.general.string = contactEmail
              #endif
              withAnimation {
                isCopied = true
              }
              DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                  isCopied = false
                }
              }
            },
            label: {
              HStack {
                HStack(spacing: 8) {
                  Image(systemName: isCopied ? "checkmark" : "envelope")
                    .foregroundStyle(isCopied ? .green : .primary)
                  Text(verbatim: contactEmail)
                }
                Spacer()
                if isCopied {
                  Text(Localization.string("COPIED"))
                    .font(.caption)
                    .foregroundStyle(.green)
                } else {
                  Image(systemName: "doc.on.doc")
                    .font(.caption)
                }
              }
              .contentShape(Rectangle())
              .padding()
              .background(.white.opacity(0.05))
              .clipShape(RoundedRectangle(cornerRadius: 12))
            }
          )
          .buttonStyle(.plain)

          Link(
            destination: URL(string: "https://www.withcaldera.com/system26/privacy-policy") ?? URL(fileURLWithPath: "")
          ) {
            HStack {
              Label(Localization.string("PRIVACY_POLICY"), systemImage: "hand.raised")
              Spacer()
              Image(systemName: "arrow.up.right")
                .font(.caption)
            }
            .padding()
            .background(.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .buttonStyle(.plain)
        }
        .font(Theme.body)
        .padding(.horizontal, 20)

        Spacer()

        VStack(spacing: 8) {
          Image("SidebarLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 44)
            .foregroundStyle(.secondary)
            .opacity(0.7)

          Text(Localization.string("OPEN_SOURCE_LICENSE"))
            .font(.caption2)
            .foregroundStyle(.secondary.opacity(0.6))
        }
        .padding(.bottom, 20)
      }
      .frame(maxWidth: 600)
      .frame(maxWidth: .infinity)
    }
    .navigationTitle(Localization.string("ABOUT"))
    #if !os(macOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
    .toolbar {
      if isPresentedAsSheet {
        ToolbarItem(placement: .confirmationAction) {
          Button(Localization.string("DONE")) {
            dismiss()
          }
        }
      }
    }
  }
}

#if DEBUG
  #Preview("About") {
    NavigationStack {
      AboutView()
        .preferredColorScheme(.dark)
    }
  }
#endif
