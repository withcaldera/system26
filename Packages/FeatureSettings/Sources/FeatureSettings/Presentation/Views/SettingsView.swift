import Combine
import Core
import DesignSystem
import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

public struct SettingsView: View {
  @Environment(\.dismiss)
  var dismiss
  public var isPresentedAsSheet: Bool

  @AppStorage("isReducedMotion")
  private var isReducedMotion = false

  public init(isPresentedAsSheet: Bool = false) {
    self.isPresentedAsSheet = isPresentedAsSheet
  }

  public var body: some View {
    settingsContainer
      .navigationTitle(Localization.string("SETTINGS"))
      #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
      .onReceive(reduceMotionPublisher) { enabled in
        isReducedMotion = enabled
      }
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

  @ViewBuilder private var settingsContainer: some View {
    #if os(macOS)
      ScrollView {
        formContent
          .formStyle(.grouped)
          .frame(maxWidth: 640)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background(.clear)
    #else
      formContent
    #endif
  }

  private var formContent: some View {
    Form {
      Section(header: Text(Localization.string("APPEARANCE"))) {
        Toggle(Localization.string("REDUCE_MOTION"), isOn: $isReducedMotion)
          .tint(Theme.accentColor)
      }
    }
    .scrollContentBackground(.hidden)
    .background(.clear)
  }

  private var reduceMotionPublisher: AnyPublisher<Bool, Never> {
    #if canImport(UIKit)
      NotificationCenter.default.publisher(
        for: UIAccessibility.reduceMotionStatusDidChangeNotification
      )
      .map { _ in UIAccessibility.isReduceMotionEnabled }
      .eraseToAnyPublisher()
    #elseif canImport(AppKit)
      NotificationCenter.default.publisher(
        for: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification
      )
      .map { _ in NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
      .eraseToAnyPublisher()
    #else
      Empty().eraseToAnyPublisher()
    #endif
  }
}

#if DEBUG
  #Preview("Settings") {
    NavigationStack {
      SettingsView()
        .preferredColorScheme(.dark)
    }
  }

  #Preview("Settings Sheet") {
    NavigationStack {
      SettingsView(isPresentedAsSheet: true)
        .preferredColorScheme(.dark)
    }
  }
#endif
