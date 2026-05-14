import Foundation
import ServiceManagement

enum FormattingPreset: String, CaseIterable {
    case formal  = "formal"
    case neutral = "neutral"
    case casual  = "casual"

    var displayName: String { rawValue.capitalized }
}

enum WhisperModelSize: String, CaseIterable {
    case base   = "base"
    case small  = "small"
    case medium = "medium"

    var displayName: String {
        switch self {
        case .base:   return "Base"
        case .small:  return "Small"
        case .medium: return "Medium"
        }
    }

    var details: String {
        switch self {
        case .base:   return "Fast · ~150 MB · Good accuracy"
        case .small:  return "Balanced · ~500 MB · Better accuracy"
        case .medium: return "Slow · ~1.5 GB · Best accuracy"
        }
    }

    var filename: String { "ggml-\(rawValue).en.bin" }
}

final class BlurtSettings: ObservableObject {
    static let shared = BlurtSettings()

    @Published var preset: FormattingPreset {
        didSet { set("blurt.preset", preset.rawValue) }
    }
    @Published var modelSize: WhisperModelSize {
        didSet { set("blurt.modelSize", modelSize.rawValue) }
    }
    @Published var alwaysShowPill: Bool {
        didSet { set("blurt.alwaysShowPill", alwaysShowPill) }
    }
    @Published var enablePunctuation: Bool {
        didSet { set("blurt.enablePunctuation", enablePunctuation) }
    }
    @Published var enableFillerRemoval: Bool {
        didSet { set("blurt.enableFillerRemoval", enableFillerRemoval) }
    }
    @Published var customFillerWords: [String] {
        didSet { set("blurt.customFillerWords", customFillerWords) }
    }
    /// Each entry is "from\tto" (tab-separated).
    @Published var wordSubstitutions: [String] {
        didSet { set("blurt.wordSubstitutions", wordSubstitutions) }
    }

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue { try SMAppService.mainApp.register() }
                else        { try SMAppService.mainApp.unregister() }
            } catch {
                print("Blurt: launch-at-login — \(error.localizedDescription)")
            }
        }
    }

    private init() {
        let d = UserDefaults.standard
        preset             = FormattingPreset(rawValue: d.string(forKey: "blurt.preset") ?? "") ?? .neutral
        modelSize          = WhisperModelSize(rawValue: d.string(forKey: "blurt.modelSize") ?? "") ?? .base
        alwaysShowPill     = d.bool(forKey: "blurt.alwaysShowPill")
        enablePunctuation  = d.object(forKey: "blurt.enablePunctuation")  == nil ? true : d.bool(forKey: "blurt.enablePunctuation")
        enableFillerRemoval = d.object(forKey: "blurt.enableFillerRemoval") == nil ? true : d.bool(forKey: "blurt.enableFillerRemoval")
        customFillerWords  = d.stringArray(forKey: "blurt.customFillerWords") ?? []
        wordSubstitutions  = d.stringArray(forKey: "blurt.wordSubstitutions") ?? []
    }

    private func set(_ key: String, _ value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
