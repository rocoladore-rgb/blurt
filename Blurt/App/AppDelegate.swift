import AppKit
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var processingTimer: Timer?
    private var processingFrame = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        Transcriber.shared.prepare()   // downloads model if absent, then loads it
        setupHotkey()
        // Show onboarding on first launch; it covers permission requests.
        OnboardingWindowController.shared.showIfNeeded()
    }

    // MARK: - Hotkey → recording → transcription pipeline

    private func setupHotkey() {
        HotkeyManager.shared.onRecordingStart = { [weak self] in
            self?.setMenuBarIcon(state: .recording)
            PillWindowController.shared.show()
            AudioRecorder.shared.requestPermissionIfNeeded { granted in
                if granted {
                    AudioRecorder.shared.startRecording()
                } else {
                    DispatchQueue.main.async {
                        self?.setMenuBarIcon(state: .idle)
                        PillWindowController.shared.showError("Mic access required")
                    }
                }
            }
        }

        HotkeyManager.shared.onRecordingStop = { [weak self] in
            AudioRecorder.shared.stopRecording()
            PillWindowController.shared.startProcessing()
            self?.runTranscription()
        }

        HotkeyManager.shared.start()
    }

    private func runTranscription() {
        let audio = AudioRecorder.shared.capturedAudio

        guard !audio.isEmpty else {
            setMenuBarIcon(state: .idle)
            PillWindowController.shared.hide()
            return
        }

        guard Transcriber.shared.isReady else {
            setMenuBarIcon(state: .idle)
            switch Transcriber.shared.state {
            case .downloading(let p):
                let pct = Int(p * 100)
                PillWindowController.shared.showError("Downloading model… \(pct)%")
            case .loadingModel:
                PillWindowController.shared.showError("Loading model…")
            default:
                PillWindowController.shared.showError("Model not ready")
            }
            return
        }

        setMenuBarIcon(state: .processing)

        Transcriber.shared.transcribe(audio) { [weak self] result in
            self?.setMenuBarIcon(state: .idle)
            switch result {
            case .success(let text):
                let formatted = FormattingEngine.shared.format(text)
                TextInserter.shared.insert(formatted)
                PillWindowController.shared.hide()
            case .failure:
                PillWindowController.shared.showError("Transcription failed")
            }
        }
    }

    // MARK: - Menubar

    enum IconState { case idle, recording, processing }

    private static let iconConfig = NSImage.SymbolConfiguration(
        pointSize: 16, weight: .regular, scale: .medium
    )
    private static let recordingConfig = NSImage.SymbolConfiguration(
        pointSize: 16, weight: .medium, scale: .medium
    )
    private static let purpleTint = NSColor(
        red: 0x6E / 255.0, green: 0x56 / 255.0, blue: 0xCF / 255.0, alpha: 1
    )

    private func setMenuBarIcon(state: IconState) {
        processingTimer?.invalidate()
        processingTimer = nil
        processingFrame = 0

        guard let button = statusItem?.button else { return }

        switch state {
        case .idle:
            let img = NSImage(systemSymbolName: "mic", accessibilityDescription: "Blurt")?
                .withSymbolConfiguration(Self.iconConfig)
            img?.isTemplate = true
            button.image = img
            button.contentTintColor = nil

        case .recording:
            let img = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Blurt recording")?
                .withSymbolConfiguration(Self.recordingConfig)
            img?.isTemplate = false
            button.image = img
            button.contentTintColor = Self.purpleTint

        case .processing:
            // Cycles through three dot-fill states to convey progress.
            let frames = ["ellipsis", "ellipsis.circle", "ellipsis.circle.fill"]
            button.contentTintColor = nil
            processingTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { [weak self] _ in
                guard let self, let button = self.statusItem?.button else { return }
                let sym = frames[self.processingFrame % frames.count]
                let img = NSImage(systemSymbolName: sym, accessibilityDescription: "Blurt processing")?
                    .withSymbolConfiguration(Self.iconConfig)
                img?.isTemplate = true
                button.image = img
                self.processingFrame += 1
            }
            processingTimer?.fire()
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }
        let img = NSImage(systemSymbolName: "mic", accessibilityDescription: "Blurt")?
            .withSymbolConfiguration(Self.iconConfig)
        img?.isTemplate = true
        button.image = img

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "Blurt", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Blurt", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
