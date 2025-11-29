import Charts
import Core
import DesignSystem
import PhotosUI
import SwiftUI

// swiftlint:disable file_length

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif
#if canImport(PencilKit)
  import PencilKit
#endif

#if os(iOS) || os(visionOS)
  struct SketchSheet: View {
    @Binding var drawing: PKDrawing?
    @Environment(\.dismiss)
    var dismiss
    @State private var temporaryDrawing = PKDrawing()

    var body: some View {
      NavigationStack {
        SketchCanvas(drawing: $temporaryDrawing)
          .navigationTitle(Localization.string("IMAGE_STYLE_SKETCH"))
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button(Localization.string("CANCEL")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button(Localization.string("DONE")) {
                drawing = temporaryDrawing
                dismiss()
              }
            }
          }
      }
      .onAppear {
        if let existing = drawing {
          temporaryDrawing = existing
        }
      }
    }
  }

  struct SketchCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
      let canvasView = PKCanvasView()
      canvasView.drawing = drawing
      canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
      canvasView.drawingPolicy = .anyInput
      canvasView.backgroundColor = .white
      canvasView.delegate = context.coordinator
      return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
      if uiView.drawing != drawing {
        uiView.drawing = drawing
      }
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
      var parent: SketchCanvas

      init(_ parent: SketchCanvas) {
        self.parent = parent
      }

      func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        parent.drawing = canvasView.drawing
      }
    }
  }

  #if DEBUG
    #Preview("Sketch Sheet") {
      SketchSheet(drawing: .constant(nil))
    }
  #endif
#endif

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public struct ImagePlaygroundView: View {
  @Bindable var viewModel: ImageGenViewModel
  @State private var spinnerRotation = 0.0
  @State private var selectedImageIndex = 0
  @State private var selectedItem: PhotosPickerItem?
  @State private var showSketchSheet = false
  @State private var isAddingConcept = false
  @State private var newConceptText = ""

  @Environment(\.horizontalSizeClass)
  var horizontalSizeClass

  var columns: [GridItem] {
    guard horizontalSizeClass == .compact else {
      return Array(repeating: GridItem(.flexible(minimum: 200), spacing: 12), count: 3)
    }
    return [GridItem(.flexible())]
  }

  let contentColumns: [GridItem] = [
    GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 24, alignment: .top)
  ]

  public init(viewModel: ImageGenViewModel) {
    self.viewModel = viewModel
  }

  func addConcept() {
    if !newConceptText.isEmpty {
      viewModel.addConcept(newConceptText)
      newConceptText = ""
      isAddingConcept = false
    }
  }

  public var body: some View {
    BenchmarkScreenContainer {
      VStack(spacing: 24) {
        metricsView

        LazyVGrid(columns: contentColumns, spacing: 24) {
          configurationView
          outputView
        }
      }
    }
    .overlay(alignment: .bottom) {
      if let err = viewModel.error {
        Text(err)
          .padding()
          .background(.red)
          .cornerRadius(8)
          .onTapGesture { viewModel.error = nil }
      }
    }
    .toolbar { toolbarItems }
    .onChange(of: viewModel.streamedImages.count) { _, newCount in
      if viewModel.isRunning && newCount > 0 {
        selectedImageIndex = newCount - 1
      }
    }
    .onChange(of: selectedItem) { _, newItem in
      Task {
        if let data = try? await newItem?.loadTransferable(type: Data.self) {
          var loadedCGImage: CGImage?
          #if os(macOS)
            if let nsImage = NSImage(data: data) {
              loadedCGImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            }
          #else
            if let uiImage = UIImage(data: data) {
              UIGraphicsBeginImageContext(uiImage.size)
              uiImage.draw(in: CGRect(origin: .zero, size: uiImage.size))
              let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()
              loadedCGImage = normalizedImage?.cgImage
            }
          #endif

          if let finalImage = loadedCGImage {
            await MainActor.run {
              viewModel.referenceImage = finalImage
            }
          }
        }
      }
    }
    #if os(iOS) || os(visionOS)
      .sheet(isPresented: $showSketchSheet) {
        SketchSheet(drawing: $viewModel.sketch)
      }
    #endif
    .task {
      Task { await viewModel.loadAvailableStyles() }
      await viewModel.ensureInitialConcepts()
    }
  }

  var metricsView: some View {
    LazyVGrid(columns: columns, spacing: 16) {
      MetricCard(
        title: Localization.string("GENERATION_TIME"),
        value: viewModel.isRunning
          ? String(format: "%.3f", viewModel.elapsedTime)
          : (viewModel.lastResult.map { String(format: "%.3f", $0.totalGenerationTime) }
            ?? Localization.string("NOT_AVAILABLE")),
        unit: "s",
        valueColor: Theme.secondaryColor,
        tooltip: Localization.string("GENERATION_TIME_TOOLTIP")
      )

      MetricCard(
        title: Localization.string("STATUS"),
        value: viewModel.isRunning
          ? Localization.string("STATUS_GENERATING")
          : (viewModel.error != nil
            ? Localization.string("STATUS_ERROR") : Localization.string("STATUS_READY")),
        unit: nil,
        valueColor: viewModel.error != nil ? .red : (viewModel.isRunning ? .yellow : .green),
        tooltip: nil
      )
    }
  }

  var configurationView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(Localization.string("CONFIGURATION"))
        .font(Theme.sectionHeader)
        .tracking(1.0)
        .foregroundStyle(.secondary)
        .padding(.leading, 8)

      VStack(alignment: .leading, spacing: 12) {
        conceptsSection
        referenceImageSection
        Spacer()

        HStack {
          Spacer()
          Button(
            action: {
              Task { viewModel.runBenchmark() }
            },
            label: {
              ZStack {
                if viewModel.isRunning {
                  Image(systemName: "square.fill")
                    .imageScale(.medium)
                    .symbolEffect(.pulse, options: .repeating, isActive: viewModel.isRunning)
                } else {
                  Image(systemName: "play.fill")
                }
              }
              .frame(width: 44, height: 44)
            }
          )
          .buttonStyle(.plain)
          .background(viewModel.isRunning ? Color.red.opacity(0.2) : Theme.accentColor.opacity(0.2))
          .clipShape(Circle())
          .overlay(
            Circle()
              .strokeBorder(viewModel.isRunning ? Color.red : Theme.accentColor, lineWidth: 1)
          )
          .disabled(viewModel.isRunning)
        }
      }
      .padding(16)
      .frame(height: 480)
      .liquidSurface()
    }
  }

  var conceptsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading, spacing: 6) {
          Text(Localization.string("STYLE"))
            .font(.caption)
            .foregroundStyle(.secondary)
            .help(Localization.string("STYLE_HELP"))

          if viewModel.availableStyles.isEmpty {
            if viewModel.isLoadingStyles {
              HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text(Localization.string("IMAGE_STYLES_LOADING"))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            } else {
              Text(Localization.string("IMAGE_STYLES_UNAVAILABLE"))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          } else {
            if let defaultStyle = viewModel.selectedStyle ?? viewModel.availableStyles.first {
              Menu(
                content: {
                  ForEach(viewModel.availableStyles, id: \.self) { style in
                    Button(
                      action: {
                        viewModel.selectedStyle = style
                      },
                      label: {
                        if viewModel.selectedStyle == style {
                          Label(style.displayName, systemImage: "checkmark")
                        } else {
                          Text(style.displayName)
                        }
                      })
                  }
                },
                label: {
                  HStack {
                    Text(viewModel.selectedStyle?.displayName ?? defaultStyle.displayName)
                      .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                  .padding(.horizontal, 12)
                  .padding(.vertical, 8)
                  .background(Color.white.opacity(0.1))
                  .clipShape(RoundedRectangle(cornerRadius: 8))
                  .overlay(
                    RoundedRectangle(cornerRadius: 8)
                      .stroke(Theme.borderColor, lineWidth: 1)
                  )
                }
              )
              .menuStyle(.button)
            }
          }
        }

        VStack(alignment: .leading, spacing: 6) {
          Text(Localization.string("IMAGES"))
            .font(.caption)
            .foregroundStyle(.secondary)
            .help(Localization.string("IMAGES_HELP"))

          HStack(spacing: 10) {
            Stepper("", value: $viewModel.requestedImageLimit, in: 1...4)
              .labelsHidden()
              .accessibilityLabel(Localization.string("IMAGES_TO_GENERATE"))
              .accessibilityValue("\(viewModel.requestedImageLimit)")
            Text("\(viewModel.requestedImageLimit)")
              .font(Font.custom("Menlo", size: 17, relativeTo: .body).monospacedDigit())
              .foregroundStyle(.primary)
          }
        }
      }

      VStack(alignment: .leading, spacing: 6) {
        Text(Localization.string("CONCEPTS_SEED"))
          .font(.caption)
          .foregroundStyle(.secondary)
          .help(Localization.string("CONCEPTS_SEED_HELP"))

        HStack(spacing: 8) {
          TextField(Localization.string("CONCEPT_PLACEHOLDER"), text: $viewModel.themeInput)
            .textFieldStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.borderColor, lineWidth: 1))
            .onSubmit {
              if !viewModel.themeInput.isEmpty {
                Task { await viewModel.generateConcepts() }
              }
            }

          Button {
            Task { await viewModel.generateConceptSeed() }
          } label: {
            ZStack {
              if viewModel.isGeneratingConcepts {
                ProgressView()
                  .controlSize(.small)
              } else {
                Image(systemName: "sparkles")
                  .foregroundStyle(Theme.accentColor)
              }
            }
            .frame(width: 44, height: 44)
          }
          .buttonStyle(.plain)
          .background(Circle().fill(Color.white.opacity(0.1)))
          .overlay(Circle().stroke(Theme.borderColor, lineWidth: 1))
          .contentShape(Circle())
          .disabled(viewModel.isGeneratingConcepts)
        }
      }

      activeConceptsList
    }
    .padding(12)
    .background(.black.opacity(0.2))
    .cornerRadius(8)
  }

  var activeConceptsList: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(Localization.string("CONCEPTS"))
        .font(.caption)
        .foregroundStyle(.secondary)
        .help(Localization.string("CONCEPTS_HELP"))

      ScrollView(.horizontal, showsIndicators: false) {
        ScrollViewReader { proxy in
          HStack(spacing: 8) {
            if viewModel.isGeneratingConcepts {
              ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 16)
                  .fill(Color.secondary.opacity(0.1))
                  .frame(width: 80, height: 32)
                  .overlay(ProgressView().controlSize(.mini))
              }
            } else {
              ForEach(viewModel.textConcepts, id: \.self) { concept in
                HStack(spacing: 6) {
                  Text(concept)
                    .font(.caption)
                    .fontWeight(.medium)

                  Button {
                    viewModel.removeConcept(concept)
                  } label: {
                    Image(systemName: "xmark")
                      .font(.system(size: 10, weight: .bold))
                  }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.accentColor.opacity(0.2))
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.accentColor.opacity(0.5), lineWidth: 1))
              }
            }

            if !viewModel.isGeneratingConcepts {
              if isAddingConcept {
                HStack {
                  TextField(Localization.string("NEW_CONCEPT"), text: $newConceptText)
                    .font(.caption)
                    .frame(width: 100)
                    .onSubmit { addConcept() }

                  Button(
                    action: {
                      addConcept()
                    },
                    label: {
                      Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    }
                  )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.cardBackground)
                .clipShape(Capsule())
                .id("AddButton")
              } else {
                Button {
                  isAddingConcept = true
                } label: {
                  Image(systemName: "plus")
                    .font(.caption)
                    .padding(8)
                    .background(Circle().fill(Theme.cardBackground))
                    .overlay(Circle().stroke(Theme.borderColor))
                }
                .id("AddButton")
              }
            }
          }
          .padding(.vertical, 4)
          .onChange(of: isAddingConcept) { _, newValue in
            if newValue {
              withAnimation { proxy.scrollTo("AddButton", anchor: .trailing) }
            }
          }
        }
      }
    }
    .frame(height: 72)
  }

  var referenceImageSection: some View {
    HStack(spacing: 20) {
      VStack(spacing: 8) {
        Text(Localization.string("FACE"))
          .font(.caption)
          .foregroundStyle(.secondary)
          .help(Localization.string("FACE_HELP"))

        if let refImage = viewModel.referenceImage {
          ZStack(alignment: .topTrailing) {
            Image(decorative: refImage, scale: 1.0, orientation: .up)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 80, height: 80)
              .cornerRadius(8)
              .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.borderColor))

            Button {
              viewModel.referenceImage = nil
              selectedItem = nil
            } label: {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .background(.white.opacity(0.5))
                .clipShape(Circle())
            }
            .offset(x: 6, y: -6)
          }
        } else {
          PhotosPicker(
            selection: $selectedItem,
            matching: .images
          ) {
            Image(systemName: "person.crop.circle.badge.plus")
              .font(.title2)
              .frame(width: 80, height: 80)
              .background(Theme.cardBackground.opacity(0.5))
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(
                  Theme.borderColor, style: StrokeStyle(lineWidth: 1, dash: [4])))
          }
          .help(Localization.string("FACE_UPLOAD_HELP"))
        }
      }

      #if os(iOS) || os(visionOS)
        VStack(spacing: 8) {
          Text(Localization.string("IMAGE_STYLE_SKETCH"))
            .font(.caption)
            .foregroundStyle(.secondary)
            .help(Localization.string("SKETCH_HELP"))

          if let sketch = viewModel.sketch {
            ZStack(alignment: .topTrailing) {
              Image(uiImage: sketch.image(from: sketch.bounds, scale: 1.0))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .background(.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.borderColor))

              Button {
                viewModel.sketch = nil
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .foregroundStyle(.red)
                  .background(.white.opacity(0.5))
                  .clipShape(Circle())
              }
              .offset(x: 6, y: -6)
            }
            .onTapGesture { showSketchSheet = true }
          } else {
            Button {
              showSketchSheet = true
            } label: {
              Image(systemName: "scribble.variable")
                .font(.title2)
                .frame(width: 80, height: 80)
                .background(Theme.cardBackground.opacity(0.5))
                .cornerRadius(8)
                .overlay(
                  RoundedRectangle(cornerRadius: 8).stroke(
                    Theme.borderColor, style: StrokeStyle(lineWidth: 1, dash: [4])))
            }
          }
        }
      #endif

      Spacer()
    }
    .buttonStyle(.plain)
  }

  var outputView: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(Localization.string("GENERATED_OUTPUT"))
        .font(Theme.sectionHeader)
        .tracking(1.0)
        .foregroundStyle(.secondary)
        .padding(.leading, 8)

      VStack(alignment: .leading, spacing: 8) {
        Text(Localization.string("RESULT"))
          .font(Theme.subheader)
          .foregroundStyle(.secondary)

        let displayedImage: Image? = {
          if !viewModel.streamedImages.isEmpty {
            let safeIndex = min(selectedImageIndex, max(viewModel.streamedImages.count - 1, 0))
            if safeIndex < viewModel.streamedImages.count {
              return viewModel.streamedImages[safeIndex]
            }
          }

          if viewModel.isRunning {
            return viewModel.partialImage
          } else if let result = viewModel.lastResult {
            if let cg = result.generatedCGImage {
              return Image(decorative: cg, scale: 1.0, orientation: .up)
            }
          }
          return nil
        }()

        ZStack {
          if viewModel.isRunning && displayedImage == nil {
            VStack(spacing: 16) {
              ProgressView().scaleEffect(1.5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
          } else if let image = displayedImage {
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 300)
              .cornerRadius(12)
              .padding(4)
          } else {
            Color.clear
              .frame(maxWidth: .infinity)
              .frame(height: 300)
          }
        }
        .frame(maxWidth: .infinity)

        if viewModel.requestedImageLimit > 1 || viewModel.streamedImages.count > 1 {
          HStack(spacing: 12) {
            ForEach(0..<viewModel.requestedImageLimit, id: \.self) { index in
              Button {
                selectedImageIndex = index
              } label: {
                ZStack {
                  if index < viewModel.streamedImages.count {
                    viewModel.streamedImages[index]
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                  } else {
                    if viewModel.isRunning {
                      ProgressView().controlSize(.mini)
                    } else {
                      Color.clear
                    }
                  }
                }
                .frame(width: 60, height: 60)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(
                      selectedImageIndex == index ? Theme.accentColor : Color.clear, lineWidth: 2)
                )
              }
              .buttonStyle(.plain)
            }
          }
          .frame(maxWidth: .infinity)
          .padding(.top, 8)
        }
      }
      .padding(20)
      .frame(height: 480)
      .liquidSurface()
    }
  }

  var toolbarItems: some ToolbarContent {
    ToolbarItem(placement: .primaryAction) {
      Button(
        action: {
          Task { viewModel.runBenchmark() }
        },
        label: {
          ZStack {
            if viewModel.isRunning {
              HStack(spacing: 6) {
                ProgressView()
                  .controlSize(.small)
                Image(systemName: "square.fill")
                  .imageScale(.medium)
                  .symbolEffect(.pulse, options: .repeating, isActive: viewModel.isRunning)
              }
            } else {
              Text(Localization.string("START_TEST"))
            }
          }
          .frame(minWidth: 44)
        }
      )
      .controlSize(.extraLarge)
      .disabled(viewModel.isRunning)
      #if os(visionOS)
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassBackgroundEffect(in: Capsule())
      #else
        .buttonStyle(.glass)
        .clipShape(Capsule())
      #endif
    }
  }
}

struct BenchmarkScreenContainer<Content: View>: View {
  let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        content
      }
      .padding(.horizontal)
      .padding(.vertical, 20)
    }
  }
}

#if DEBUG
  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  #Preview("Image Playground") {
    NavigationStack {
      ImagePlaygroundView(viewModel: .preview)
        .preferredColorScheme(.dark)
    }
  }
#endif
