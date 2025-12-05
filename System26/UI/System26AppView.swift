import Core
import DesignSystem
import FeatureImageGen
import FeatureLLM
import FeatureSettings
import FeatureVisualIntelligence
import SwiftUI

#if os(iOS)
  import UIKit
#endif

enum SidebarItem: Hashable {
  case llm
  case settings
  case imagePlayground
  case visualIntelligence
  case about
}

struct System26AppView: View {
  let llmViewModel: LLMDashboardViewModel
  let imageGenViewModel: ImageGenViewModel
  let visualIntelligenceViewModel: VisualIntelligenceBenchmarkViewModel
  @Binding var isLiquidBackgroundVisible: Bool

  @State private var columnVisibility = NavigationSplitViewVisibility.all
  @State private var selection: SidebarItem?
  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  var verticalSizeClass

  private var shouldCollapseSidebarOnSelect: Bool {
    #if os(iOS)
      return UIDevice.current.userInterfaceIdiom == .pad
        && UIScreen.main.bounds.height > UIScreen.main.bounds.width
    #else
      return false
    #endif
  }

  private var shouldCollapseSidebarOnTap: Bool { shouldCollapseSidebarOnSelect }

  private func updateLiquidBackgroundVisibility() {
    let current = selection ?? .llm
    let isLiveCamera = visualIntelligenceViewModel.configuration.mode == .liveCamera
    isLiquidBackgroundVisible = !(current == .visualIntelligence && isLiveCamera)
  }

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      List(selection: $selection) {
        Section {
          NavigationLink(value: SidebarItem.llm) {
            Label(Localization.string("LANGUAGE_MODELS"), systemImage: "text.bubble")
          }
          .accessibilityIdentifier("sidebar_llm")

          NavigationLink(value: SidebarItem.imagePlayground) {
            Label(Localization.string("IMAGE_DIFFUSION"), systemImage: "photo.on.rectangle")
          }
          .accessibilityIdentifier("sidebar_image")

          NavigationLink(value: SidebarItem.visualIntelligence) {
            Label(Localization.string("VISUAL_INTELLIGENCE"), systemImage: "eye.fill")
          }
          .accessibilityIdentifier("sidebar_vision")
          #if os(visionOS)
            .disabled(true)
            .foregroundStyle(.secondary)
          #endif
        } header: {
          VStack(alignment: .leading, spacing: 18) {
            Text("System26")
              .font(.custom("Menlo", size: 22).weight(.bold))
              .foregroundStyle(.white)
            Text(Localization.string("FEATURES"))
              .font(Theme.sectionHeader)
              .foregroundStyle(.secondary)
          }
          .padding(.bottom, 10)
        }

        Section {
          NavigationLink(value: SidebarItem.settings) {
            Label(Localization.string("SETTINGS"), systemImage: "gearshape")
          }
          .accessibilityIdentifier("sidebar_settings")

          NavigationLink(value: SidebarItem.about) {
            Label(Localization.string("ABOUT"), systemImage: "info.circle")
          }
          .accessibilityIdentifier("sidebar_about")
        }
      }
      .navigationTitle(horizontalSizeClass == .compact ? "" : "System26")
      .scrollContentBackground(.hidden)
      .safeAreaInset(edge: .bottom) {
        if verticalSizeClass != .compact {
          Link(destination: URL(string: "https://www.withcaldera.com/") ?? URL(fileURLWithPath: "")) {
            Image("SidebarLogo")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 24)
              .foregroundColor(.primary)
              .opacity(0.7)
              .frame(maxWidth: .infinity, alignment: .trailing)
              .padding(.horizontal, 20)
              .padding(.bottom, 12)
          }
          .buttonStyle(.plain)
        }
      }
      .navigationSplitViewColumnWidth(min: 200, ideal: 250)
    } detail: {
      ZStack {
        switch selection ?? .llm {
        case .llm:
          LLMDashboardView(viewModel: llmViewModel)

        case .settings:
          SettingsView()

        case .imagePlayground:
          ImagePlaygroundView(viewModel: imageGenViewModel)

        case .visualIntelligence:
          VisualIntelligenceBenchmarkView(viewModel: visualIntelligenceViewModel)

        case .about:
          AboutView()
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        #if os(iOS)
          if shouldCollapseSidebarOnTap && columnVisibility != .detailOnly {
            columnVisibility = .detailOnly
          }
        #endif
      }
    }
    .navigationSplitViewStyle(.balanced)
    .background(.clear)
    .preferredColorScheme(.dark)
    .onPreferenceChange(LiquidBackgroundVisibilityPreferenceKey.self) { isVisible in
      isLiquidBackgroundVisible = isVisible
    }
    .onAppear { updateLiquidBackgroundVisibility() }
    .onChange(of: selection) { oldValue, _ in
      switch oldValue {
      case .llm:
        llmViewModel.abortBenchmark()

      case .settings:
        break

      case .imagePlayground:
        imageGenViewModel.stopBenchmark()

      case .visualIntelligence:
        visualIntelligenceViewModel.stopBenchmark()
        visualIntelligenceViewModel.resetToSyntheticModeIfLive()

      default:
        break
      }

      if shouldCollapseSidebarOnSelect {
        columnVisibility = .detailOnly
      }

      updateLiquidBackgroundVisibility()
    }
    .onChange(of: visualIntelligenceViewModel.configuration.mode) { _, _ in
      updateLiquidBackgroundVisibility()
    }
    .onAppear {
      if horizontalSizeClass == .compact {
        selection = nil
      } else {
        selection = .llm
      }
    }
  }
}

#if DEBUG
  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("System26 App Shell") {
    System26AppView(
      llmViewModel: .preview,
      imageGenViewModel: .preview,
      visualIntelligenceViewModel: .previewSynthetic(),
      isLiquidBackgroundVisible: .constant(true)
    )
    .preferredColorScheme(.dark)
  }
#endif
