import AppKit
import SwiftUI

// MARK: - Controller

final class PillWindowController: NSObject, ObservableObject {
    static let shared = PillWindowController()

    enum PillState { case recording, processing, error(String) }

    @Published private(set) var isShowing  = false
    @Published private(set) var pillState: PillState = .recording

    var isProcessing: Bool {
        if case .processing = pillState { return true }
        return false
    }

    private var panel: PillPanel?
    private var errorDismissWork: DispatchWorkItem?

    private override init() { super.init() }

    /// Shows the pill with the waveform in recording state.
    func show() {
        pillState = .recording
        if panel == nil { panel = PillPanel() }
        guard !isShowing else { return }
        panel?.positionAtBottomCenter()
        panel?.orderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) { [weak self] in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self?.isShowing = true
            }
        }
    }

    /// Switches the pill content from waveform to a processing spinner.
    func startProcessing() {
        pillState = .processing
    }

    /// Shows a short error message in the pill, then auto-dismisses after `duration` seconds.
    func showError(_ message: String, duration: TimeInterval = 2.5) {
        errorDismissWork?.cancel()
        pillState = .error(message)
        if !isShowing { show() }
        let work = DispatchWorkItem { [weak self] in self?.hide() }
        errorDismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }

    /// Animates the pill out, then orders the window off screen.
    func hide() {
        errorDismissWork?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            isShowing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.panel?.orderOut(nil)
            self?.pillState = .recording
        }
    }
}

// MARK: - NSPanel

private final class PillPanel: NSPanel {

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 64),
            styleMask:   [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing:     .buffered,
            defer:       false
        )
        isOpaque              = false
        backgroundColor       = .clear
        level                 = .floating
        ignoresMouseEvents    = true
        isMovableByWindowBackground = false
        collectionBehavior    = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        hasShadow             = false

        let hosting = NSHostingView(rootView: PillContentView())
        hosting.frame            = NSRect(x: 0, y: 0, width: 320, height: 64)
        hosting.autoresizingMask = [.width, .height]
        contentView = hosting
    }

    override var canBecomeKey:  Bool { false }
    override var canBecomeMain: Bool { false }

    func positionAtBottomCenter() {
        guard let screen = NSScreen.main else { return }
        // Use visibleFrame so the pill sits 48 pt above the Dock.
        let vf = screen.visibleFrame
        let x  = vf.midX - 160   // half of 320 pt width
        let y  = vf.minY + 48
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}

// MARK: - SwiftUI pill content

private struct PillContentView: View {
    @ObservedObject private var controller = PillWindowController.shared

    @State private var scale:   CGFloat = 0.85
    @State private var opacity: Double  = 0.0

    var body: some View {
        ZStack {
            PillBackground()
                .clipShape(Capsule())

            pillContent
        }
        .frame(width: 320, height: 64)
        .scaleEffect(scale)
        .opacity(opacity)
        .onReceive(controller.$isShowing) { showing in
            if showing {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scale = 1.0; opacity = 1.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    scale = 0.9; opacity = 0.0
                }
            }
        }
    }

    @ViewBuilder
    private var pillContent: some View {
        switch controller.pillState {
        case .recording:
            WaveformView()
                .padding(.horizontal, 16)
                .transition(.opacity)

        case .processing:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(0.75)
                .transition(.opacity)

        case .error(let message):
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .transition(.opacity)
        }
    }
}

// MARK: - Dark visual effect background

private struct PillBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material      = .hudWindow       // always-dark frosted glass
        v.blendingMode  = .behindWindow
        v.state         = .active
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
