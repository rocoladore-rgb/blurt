import SwiftUI
import AVFoundation

// MARK: - Window controller

final class OnboardingWindowController: NSObject {
    static let shared = OnboardingWindowController()

    private var window: NSWindow?

    private override init() { super.init() }

    func showIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "blurt.onboardingComplete") else { return }
        show()
    }

    func show() {
        if window == nil {
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 560, height: 460),
                styleMask:   [.titled, .closable, .fullSizeContentView],
                backing:     .buffered,
                defer:       false
            )
            w.titlebarAppearsTransparent = true
            w.isMovableByWindowBackground = true
            w.center()
            w.contentView = NSHostingView(rootView: OnboardingView(controller: self))
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func complete() {
        UserDefaults.standard.set(true, forKey: "blurt.onboardingComplete")
        window?.close()
        window = nil
    }
}

// MARK: - Root view

struct OnboardingView: View {
    let controller: OnboardingWindowController
    @State private var step = 0

    var body: some View {
        ZStack {
            // Dark background matching brand
            Color(red: 0x10/255.0, green: 0x0A/255.0, blue: 0x28/255.0)
                .ignoresSafeArea()

            switch step {
            case 0: WelcomeStep   { withAnimation(.easeInOut(duration: 0.3)) { step = 1 } }
            case 1: AccessStep    { withAnimation(.easeInOut(duration: 0.3)) { step = 2 } }
            case 2: MicStep       { withAnimation(.easeInOut(duration: 0.3)) { step = 3 } }
            case 3: ModelStep     { controller.complete() }
            default: EmptyView()
            }
        }
        .frame(width: 560, height: 460)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Shared layout helpers

private struct StepContainer<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let buttonLabel: String
    let action: () -> Void
    @ViewBuilder let extra: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(iconColor)
                .padding(.bottom, 24)

            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 10)

            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
                .padding(.bottom, 32)

            extra()

            Spacer()

            Button(action: action) {
                Text(buttonLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 200)
                    .padding(.vertical, 10)
                    .background(Color(red: 0x6E/255.0, green: 0x56/255.0, blue: 0xCF/255.0))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 48)
    }
}

// MARK: - Step 1: Welcome

private struct WelcomeStep: View {
    let next: () -> Void

    var body: some View {
        StepContainer(
            icon: "waveform.and.mic",
            iconColor: Color(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0),
            title: "Welcome to Blurt",
            subtitle: "Hold a key, speak, release. Blurt transcribes your voice and types it anywhere — fast, private, and completely on-device.",
            buttonLabel: "Get Started",
            action: next
        ) {
            HStack(spacing: 28) {
                FeaturePill(icon: "lock.fill",      label: "100% Private")
                FeaturePill(icon: "bolt.fill",      label: "Instant")
                FeaturePill(icon: "wifi.slash",     label: "Offline")
            }
            .padding(.bottom, 8)
        }
    }
}

private struct FeaturePill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0))
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.06))
        .clipShape(Capsule())
    }
}

// MARK: - Step 2: Accessibility

private struct AccessStep: View {
    let next: () -> Void
    @State private var granted = AXIsProcessTrusted()

    var body: some View {
        StepContainer(
            icon: "keyboard",
            iconColor: Color(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0),
            title: "Enable Keyboard Access",
            subtitle: "Blurt needs Accessibility access to type transcribed text into any app on your Mac.",
            buttonLabel: granted ? "Continue" : "Grant Access",
            action: {
                if granted { next() }
                else { requestAccess() }
            }
        ) {
            PermissionRow(
                icon: granted ? "checkmark.circle.fill" : "circle",
                label: "Accessibility",
                detail: granted ? "Granted" : "Required to type in other apps",
                granted: granted
            )
            .padding(.bottom, 8)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            granted = AXIsProcessTrusted()
        }
    }

    private func requestAccess() {
        let opts: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(opts)
    }
}

// MARK: - Step 3: Microphone

private struct MicStep: View {
    let next: () -> Void
    @State private var status = AVCaptureDevice.authorizationStatus(for: .audio)

    var body: some View {
        StepContainer(
            icon: "mic.fill",
            iconColor: Color(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0),
            title: "Allow Microphone",
            subtitle: "Blurt records your voice only while you hold the hotkey. Audio never leaves your Mac.",
            buttonLabel: status == .authorized ? "Continue" : "Allow Microphone",
            action: {
                if status == .authorized { next() }
                else { requestMic() }
            }
        ) {
            PermissionRow(
                icon: status == .authorized ? "checkmark.circle.fill" : "circle",
                label: "Microphone",
                detail: status == .authorized ? "Granted" : "Required to hear your voice",
                granted: status == .authorized
            )
            .padding(.bottom, 8)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            status = AVCaptureDevice.authorizationStatus(for: .audio)
        }
    }

    private func requestMic() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                status = AVCaptureDevice.authorizationStatus(for: .audio)
                if granted { next() }
            }
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let label: String
    let detail: String
    let granted: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(granted ? .green : .white.opacity(0.3))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.callout.weight(.medium)).foregroundStyle(.white)
                Text(detail).font(.caption).foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(maxWidth: 360)
    }
}

// MARK: - Step 4: Model download

private struct ModelStep: View {
    let finish: () -> Void
    @State private var state = Transcriber.shared.state

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: modelIcon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0))
                .padding(.bottom, 24)

            Text("Downloading Speech Model")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 10)

            Text("Blurt uses a 150 MB on-device model. This downloads once and never needs the internet again.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
                .padding(.bottom, 32)

            progressContent

            Spacer()

            if case .ready = state {
                Button(action: finish) {
                    Text("Start Using Blurt")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 200)
                        .padding(.vertical, 10)
                        .background(Color(red: 0x6E/255.0, green: 0x56/255.0, blue: 0xCF/255.0))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            } else {
                // Spacer to keep layout stable while downloading
                Color.clear.frame(height: 40)
            }

            Color.clear.frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 48)
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            state = Transcriber.shared.state
        }
    }

    private var modelIcon: String {
        switch state {
        case .ready:       return "checkmark.circle.fill"
        case .error:       return "xmark.circle.fill"
        default:           return "arrow.down.circle"
        }
    }

    @ViewBuilder
    private var progressContent: some View {
        switch state {
        case .downloading(let progress):
            VStack(spacing: 12) {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(Color(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0))
                    .frame(maxWidth: 360)
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        case .loadingModel:
            HStack(spacing: 10) {
                ProgressView().progressViewStyle(.circular).tint(.white).scaleEffect(0.75)
                Text("Loading model…")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.6))
            }
        case .ready:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Model ready").font(.callout).foregroundStyle(.white.opacity(0.8))
            }
        case .error(let msg):
            VStack(spacing: 8) {
                Text("Download failed").font(.callout.weight(.medium)).foregroundStyle(.red)
                Text(msg).font(.caption).foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        default:
            HStack(spacing: 10) {
                ProgressView().progressViewStyle(.circular).tint(.white).scaleEffect(0.75)
                Text("Preparing…")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}
