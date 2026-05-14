# Blurt — Build Progress

Last updated: 2026-05-14 (v1.0.1 released)  
Build environment: Xcode 26 / Swift 6.3.2 (SWIFT_VERSION=5.0) / macOS 13+ deployment target

---

## Phase Status

| Phase | Name | Status |
|---|---|---|
| 1 | Project Scaffold | ✅ Complete |
| 2 | Global Hotkey (HotkeyManager) | ✅ Complete |
| 3 | Audio Recording (AudioRecorder) | ✅ Complete |
| 4 | whisper.cpp Integration (Transcriber) | ✅ Complete |
| 5 | Text Insertion (TextInserter) | ✅ Complete |
| 6 | Formatting Engine | ✅ Complete |
| 7 | Floating Pill UI + Waveform | ✅ Complete |
| 8 | Settings Window | ✅ Complete |
| 9 | Polish | ✅ Complete |
| 10 | Distribution | ✅ Complete |

---

## Phase 1 — Project Scaffold ✅

### What was built

- **`Blurt.xcodeproj/project.pbxproj`** — manually crafted Xcode project file (no Xcode GUI used)
- **`Blurt/App/BlurtApp.swift`** — `@main` SwiftUI entry point
- **`Blurt/App/AppDelegate.swift`** — menubar setup + full pipeline wiring
- **`Blurt/App/Info.plist`** — app metadata + permission strings
- **`Blurt/Resources/Assets.xcassets`** — placeholder AppIcon + AccentColor

### Key technical decisions

**Manually crafted project.pbxproj with `objectVersion = 60`**  
Xcode 26 requires objectVersion 60 (Xcode 14+). All UUIDs use a sequential 24-character hex scheme starting from `000000000000000000000001`. This makes the file human-readable and diff-friendly. Normal Xcode-generated projects use random UUIDs.

**`@NSApplicationDelegateAdaptor` + `Settings { EmptyView() }` scene**  
SwiftUI `@main` apps require at least one `Scene`. Since Blurt has no windows, `Settings { EmptyView() }` is the minimal valid scene. All real lifecycle logic lives in `AppDelegate`. This pattern gives full `NSApplicationDelegate` control while satisfying the SwiftUI app entry point requirement.

**`LSUIElement = true` in Info.plist**  
Hides Blurt from the Dock and makes it a pure menubar app. Without this, the app would show a Dock icon and an unwanted App menu.

**`SWIFT_STRICT_CONCURRENCY = targeted`, `SWIFT_VERSION = 5.0`**  
`targeted` applies Swift 6 concurrency checking only where there are explicit async/await or actor annotations, avoiding false positives in the mostly-sync codebase. `SWIFT_VERSION = 5.0` is the pragma version used in build settings (not the compiler version).

**`GENERATE_INFOPLIST_FILE = NO`**  
Uses a hand-written `Info.plist` at `Blurt/App/Info.plist` instead of letting Xcode auto-generate it, giving full control over `LSUIElement` and usage description strings.

**Deleted nested Xcode project**  
When initially exploring the project directory, there was a pre-existing Xcode template project at `Blurt/Blurt/Blurt.xcodeproj` with SwiftUI template files. This was deleted entirely; the real project lives at the root level `Blurt.xcodeproj`.

### pbxproj UUID map

| UUID | Object |
|---|---|
| `000000000000000000000001` | PBXBuildFile — BlurtApp.swift in Sources |
| `000000000000000000000002` | PBXBuildFile — AppDelegate.swift in Sources |
| `000000000000000000000003` | PBXBuildFile — Assets.xcassets in Resources |
| `000000000000000000000004` | PBXBuildFile — HotkeyManager.swift in Sources |
| `000000000000000000000005` | PBXBuildFile — AudioRecorder.swift in Sources |
| `000000000000000000000006` | PBXBuildFile — Transcriber.swift in Sources |
| `000000000000000000000010` | PBXFileReference — BlurtApp.swift |
| `000000000000000000000011` | PBXFileReference — AppDelegate.swift |
| `000000000000000000000012` | PBXFileReference — Assets.xcassets |
| `000000000000000000000013` | PBXFileReference — Info.plist |
| `000000000000000000000015` | PBXFileReference — Blurt.app (product) |
| `000000000000000000000016` | PBXFileReference — HotkeyManager.swift |
| `000000000000000000000017` | PBXFileReference — AudioRecorder.swift |
| `000000000000000000000018` | PBXFileReference — Transcriber.swift |
| `000000000000000000000020` | PBXGroup — root |
| `000000000000000000000021` | PBXGroup — Blurt/ |
| `000000000000000000000022` | PBXGroup — App/ |
| `000000000000000000000023` | PBXGroup — Resources/ |
| `000000000000000000000024` | PBXGroup — Products |
| `000000000000000000000025` | PBXGroup — Core/ |
| `000000000000000000000030` | PBXNativeTarget — Blurt |
| `000000000000000000000031` | PBXProject |
| `000000000000000000000040` | PBXSourcesBuildPhase |
| `000000000000000000000041` | PBXResourcesBuildPhase |
| `000000000000000000000042` | PBXFrameworksBuildPhase |
| `000000000000000000000050` | XCBuildConfiguration — Debug (project-level) |
| `000000000000000000000051` | XCBuildConfiguration — Release (project-level) |
| `000000000000000000000052` | XCBuildConfiguration — Debug (target-level) |
| `000000000000000000000053` | XCBuildConfiguration — Release (target-level) |
| `000000000000000000000060` | XCConfigurationList — project |
| `000000000000000000000061` | XCConfigurationList — target |
| `AA0000000000000000000001` | XCRemoteSwiftPackageReference — **BROKEN, must be removed** |
| `AA0000000000000000000002` | XCSwiftPackageProductDependency — **BROKEN, must be removed** |

Next available UUID for new objects: `000000000000000000000070` and up.

---

## Phase 2 — Global Hotkey ✅

**File:** `Blurt/Core/HotkeyManager.swift`

### What was built

- Singleton `HotkeyManager` with `onRecordingStart` / `onRecordingStop` callbacks
- `CGEvent` tap on `.cghidEventTap` monitoring `flagsChanged`, `keyDown`, `keyUp`
- Fn key detection: `event.flags.contains(.maskSecondaryFn)` on `.flagsChanged` events
- `isFnKeyDown: Bool` guard prevents duplicate start/stop events
- Accessibility permission check with `AXIsProcessTrusted()` + auto-prompt via `AXIsProcessTrustedWithOptions`
- `CFRunLoopSource` registered on main run loop

### Key technical decisions

**`CGEventMaskBit()` is unavailable in Swift on Xcode 26**  
This C macro is not bridged to Swift. Fixed by manual bit shifting:
```swift
let mask: CGEventMask =
    (1 << CGEventType.flagsChanged.rawValue) |
    (1 << CGEventType.keyDown.rawValue) |
    (1 << CGEventType.keyUp.rawValue)
```

**Fn key requires `.flagsChanged` + `.maskSecondaryFn`, not a keycode**  
The Fn key is a modifier on macOS, not a standard key. It fires `.flagsChanged` events with the `NX_SECONDARYFNMASK` flag set, which maps to `CGEventFlags.maskSecondaryFn` in Swift. A standard keycode listener would miss it entirely.

**`.cghidEventTap` at `.headInsertEventTap`**  
HID-level tap (before the event reaches any application) ensures the hotkey works regardless of which app has focus.

---

## Phase 3 — Audio Recording ✅

**File:** `Blurt/Core/AudioRecorder.swift`

### What was built

- Singleton `AudioRecorder` with `@Published var amplitude: Float` and `@Published var isRecording: Bool`
- `AVAudioEngine` input tap: 1024-frame buffers (~23ms at 44.1kHz)
- Real-time `AVAudioConverter`: hardware format → 16kHz mono Float32 PCM (whisper.cpp required format)
- `vDSP_rmsqv` (Accelerate framework) per-buffer RMS amplitude calculation
- `capturedAudio: [Float]` accumulates all converted frames during recording
- `requestPermissionIfNeeded()` handles `.authorized`, `.notDetermined`, `.denied` with main-thread callback
- `engine.stop()` flushes in-flight tap callbacks before `capturedAudio` is read — thread-safe by design

### Key technical decisions

**1024-frame tap buffers**  
~23ms at 44.1kHz. Small enough for smooth waveform animation (Phase 7 WaveformView needs responsive amplitude updates), large enough to avoid excessive CPU from too-frequent callbacks.

**`AVAudioConverter` in every tap callback**  
whisper.cpp strictly requires 16kHz mono Float32 PCM. The converter is created once when recording starts (`converter = AVAudioConverter(from: hwFormat, to: Self.whisperFormat)`) and reused per-buffer. The output capacity accounts for the sample rate ratio with `+ 0.5` for rounding.

**`vDSP_rmsqv` instead of a manual loop**  
Accelerate's vectorised RMS is dramatically faster on Apple Silicon. Computes `sqrt(mean(x²))` over all samples in a single BLAS call.

**`engine.stop()` before reading `capturedAudio`**  
`AVAudioEngine.stop()` flushes the audio unit graph and guarantees all tap callbacks have completed before returning. This means `capturedAudio` is safe to read immediately after `stopRecording()` returns, with no locks or semaphores needed.

---

## Phase 4 — whisper.cpp Integration ✅

**Build status:** BUILD SUCCEEDED (zero errors; upstream ggml.c integer-precision warnings are expected and harmless).

### What was built

**`Blurt/Core/Transcriber.swift`** — complete:
- `TranscriberState` enum: `.idle`, `.downloading(progress: Double)`, `.loadingModel`, `.ready`, `.transcribing`, `.error(String)`
- `prepare()` — downloads model if absent, then loads it
- `downloadModel()` — `URLSession.downloadTask` with KVO progress observation, HuggingFace User-Agent header, saves to `~/Library/Application Support/Blurt/ggml-base.en.bin`
- `loadModel()` — `Whisper(fromFileURL:)` on background `DispatchQueue`
- `transcribe(_ samples: [Float], completion:)` — calls `whisper.transcribe(audioFrames:)`, joins segments, delivers on main thread

**`Blurt/Vendors/SwiftWhisper/`** — vendored in full:
- `Swift/` — 7 SwiftWhisper 1.2.0 wrapper files (Whisper, Segment, WhisperParams, WhisperDelegate, WhisperError, WhisperLanguage, WhisperSamplingStrategy)
- `whisper_cpp/whisper.cpp` — 185KB, from ggerganov/whisper.cpp@95b02d7
- `whisper_cpp/ggml.c` — 497KB
- `whisper_cpp/ggml.h` — 38KB
- `whisper_cpp/include/whisper.h` — 24KB (at root of that repo, not in an `include/` subdir)

**`Blurt/Blurt-Bridging-Header.h`** — `#include "whisper.h"` (finds it via HEADER_SEARCH_PATHS)

### Key technical decisions

**SPM failed; pivoted to vendoring**  
Xcode 26 does not recognise manually-crafted `XCRemoteSwiftPackageReference` entries in a hand-written `project.pbxproj`. `xcodebuild -resolvePackageDependencies` returned empty results, build failed with "Missing package product 'SwiftWhisper'". Solution: download SwiftWhisper Swift wrapper files and whisper.cpp C/C++ source directly into `Blurt/Vendors/`.

**whisper.h lives at repo root, not in `include/`**  
At commit `95b02d76b04d18e4ce37ed8353a1f0797f1717ea`, the whisper.cpp repo has `whisper.h` at the root, not in an `include/` subdirectory. The file was downloaded to `whisper_cpp/include/whisper.h` in the vendor tree to keep the directory structure clean, with `$(SRCROOT)/Blurt/Vendors/SwiftWhisper/whisper_cpp/include` in `HEADER_SEARCH_PATHS`.

**Bridging header instead of Clang module**  
The SwiftWhisper Swift wrapper files originally used `import whisper_cpp` (a Clang module). In the vendored approach, all three imports were removed (`import SwiftWhisper` from Transcriber.swift, `import whisper_cpp` from Whisper.swift and WhisperParams.swift) and `SWIFT_OBJC_BRIDGING_HEADER` points to `Blurt/Blurt-Bridging-Header.h` instead. C functions become globally visible.

**HEADER_SEARCH_PATHS covers two directories**  
`whisper.cpp` includes `"whisper.h"` (needs the `include/` dir) and `"ggml.h"` (needs the `whisper_cpp/` dir). Both are in HEADER_SEARCH_PATHS.

### pbxproj UUID additions (Phase 4)

| UUID | Object |
|---|---|
| `000000000000000000000070` | PBXGroup — Vendors/ |
| `000000000000000000000071` | PBXGroup — SwiftWhisper/ |
| `000000000000000000000072` | PBXGroup — Swift/ |
| `000000000000000000000073` | PBXGroup — whisper_cpp/ |
| `000000000000000000000074` | PBXGroup — include/ |
| `000000000000000000000075` | PBXFileReference — Segment.swift |
| `000000000000000000000076` | PBXFileReference — Whisper.swift |
| `000000000000000000000077` | PBXFileReference — WhisperDelegate.swift |
| `000000000000000000000078` | PBXFileReference — WhisperError.swift |
| `000000000000000000000079` | PBXFileReference — WhisperLanguage.swift |
| `000000000000000000000080` | PBXFileReference — WhisperParams.swift |
| `000000000000000000000081` | PBXFileReference — WhisperSamplingStrategy.swift |
| `000000000000000000000082` | PBXFileReference — whisper.cpp (C++) |
| `000000000000000000000083` | PBXFileReference — ggml.c |
| `000000000000000000000084` | PBXFileReference — ggml.h |
| `000000000000000000000085` | PBXFileReference — whisper.h |
| `000000000000000000000086` | PBXFileReference — Blurt-Bridging-Header.h |
| `000000000000000000000087`–`000000000000000000000095` | PBXBuildFile — vendored sources in Sources |

Next available UUID: `000000000000000000000096` and up.

---

## Current AppDelegate.swift pipeline state

The pipeline stubs in `AppDelegate.swift` show which phases have been wired vs are waiting:

```swift
// onRecordingStart callback:
AudioRecorder.shared.requestPermissionIfNeeded { granted in
    guard granted else { return }
    AudioRecorder.shared.startRecording()
}
// Phase 7: PillWindowController.shared.show()   ← not yet wired

// onRecordingStop callback:
AudioRecorder.shared.stopRecording()
self?.runTranscription()
// Phase 7: PillWindowController.shared.hide()   ← not yet wired

// runTranscription() result handler:
case .success(let text):
    print("Blurt: \"\(text)\"")
    TextInserter.shared.insert(text)      // ✅ Phase 5 wired
```

**Current end-to-end flow (fully operational):**
> Hold Fn → `onRecordingStart` → mic records → release Fn → `onRecordingStop` → whisper transcribes → `TextInserter` types text into focused app

---

## File inventory — complete current state

```
Blurt.xcodeproj/
├── project.pbxproj                      ✅ valid — has 2 broken SPM entries to remove (AA... UUIDs)
└── project.xcworkspace/
    └── xcshareddata/swiftpm/
        └── Package.resolved             ⚠️  leftover from SPM attempt, now irrelevant

Blurt/
├── App/
│   ├── BlurtApp.swift                   ✅ complete
│   ├── AppDelegate.swift                ✅ complete (Phase 5 and 7 lines commented out)
│   └── Info.plist                       ✅ complete
├── Core/
│   ├── HotkeyManager.swift              ✅ complete
│   ├── AudioRecorder.swift              ✅ complete
│   ├── Transcriber.swift                ✅ complete
│   └── TextInserter.swift               ✅ complete
├── Models/
│   └── BlurtSettings.swift              ✅ complete
├── Formatting/
│   ├── FillerWords.swift                ✅ complete
│   └── FormattingEngine.swift           ✅ complete
├── Vendors/
│   └── SwiftWhisper/
│       ├── Swift/
│       │   ├── Whisper.swift            ✅ complete (import whisper_cpp removed)
│       │   ├── WhisperParams.swift      ✅ complete (import whisper_cpp removed)
│       │   ├── Segment.swift            ✅ complete
│       │   ├── WhisperDelegate.swift    ✅ complete
│       │   ├── WhisperError.swift       ✅ complete
│       │   ├── WhisperLanguage.swift    ✅ complete
│       │   └── WhisperSamplingStrategy.swift  ✅ complete
│       └── whisper_cpp/
│           ├── include/
│           │   └── whisper.h            ✅ 24KB real source from ggerganov/whisper.cpp@95b02d7
│           ├── whisper.cpp              ✅ 185KB real source
│           ├── ggml.h                   ✅ 38KB real source
│           └── ggml.c                   ✅ 497KB real source
├── Blurt-Bridging-Header.h              ✅ complete
└── Resources/
    └── Assets.xcassets/                 ✅ placeholder icons present
```

---

## Phases 5–10 — not yet started

### Phase 5 — TextInserter ✅

**File:** `Blurt/Core/TextInserter.swift`

`CGEvent` keyboard simulation. Iterates Unicode scalars, encoding each as one or two UTF-16 `UniChar` values (handles BMP and surrogate pairs), then posts key-down + key-up via `.cghidEventTap`. No virtual key code needed — `keyboardSetUnicodeString` handles all characters directly. Wired into `AppDelegate.runTranscription()` replacing the `print` call. The accessibility permission already granted in Phase 2 (`AXIsProcessTrusted()`) covers text insertion too.

pbxproj additions: file ref `000000000000000000000097`, build file `000000000000000000000096`. Next available UUID: `000000000000000000000098`.

### Phase 6 — Formatting Engine ✅

**Files:** `Blurt/Formatting/FormattingEngine.swift`, `Blurt/Formatting/FillerWords.swift`, `Blurt/Models/BlurtSettings.swift`

**BlurtSettings** — `ObservableObject` singleton. Persists `preset: FormattingPreset` (Formal/Neutral/Casual, default Neutral) to `UserDefaults` via `@Published` + `didSet`. Ready to bind in Phase 8 SettingsView.

**FillerWords** — Two lists:
- `unconditional` (always removed, never legitimate vocabulary): um, uh, you know, you know what I mean, I mean, sort of, kind of, basically, literally
- `contextual` (removed only when comma-delimited or at sentence boundary, to avoid false positives on "I like pizza" / "turn right" / "I just got home"): actually, right, just, like, so

**FormattingEngine** — Per-preset pipeline:
- **Casual**: filler removal + whitespace cleanup
- **Neutral**: above + terminal punctuation + sentence capitalisation
- **Formal**: above + contraction expansion (29 pairs: won't→will not, I'm→I am, etc.)

Three filler removal strategies: `removeGlobally` (word-boundary in all positions), `removeContextual` (start+comma, between commas, before terminal punctuation only). `cleanArtifacts` collapses multiple spaces, fixes doubled commas, removes space-before-punctuation.

Wired in `AppDelegate.runTranscription()`: `FormattingEngine.shared.format(text)` sits between `Transcriber` output and `TextInserter.shared.insert()`.

pbxproj additions: fileRefs 098–100, buildFiles 101–103, groups 104 (Models) and 105 (Formatting). Next available UUID: `000000000000000000000106`.

### Phase 7 — Floating Pill ✅

**Files:** `Blurt/UI/PillWindow.swift`, `Blurt/UI/WaveformView.swift`

**PillWindowController** — `ObservableObject` singleton. `show()` creates the panel on first call, positions it, springs it in. `startProcessing()` flips `isProcessing` to swap waveform→spinner. `hide()` animates out then orders window off-screen after 0.25s.

**PillPanel** (NSPanel subclass) — `.nonactivatingPanel | .borderless | .fullSizeContentView`, `.floating` level, `ignoresMouseEvents = true`, `hasShadow = false`, `canBecomeKey/Main = false`. Positions 48pt above Dock using `screen.visibleFrame`.

**WaveformView** — 28 bars, 2.5pt wide, 3pt gap. Gaussian bell curve (σ = barCount/3) for edge taper. Per-buffer jitter (±45%) for organic look. Spring animation (response: 0.15, damping: 0.6). Gradient `#6E56CF→#8B5CF6` bottom-to-top. Resets to `minHeight` when `isProcessing` becomes false.

**PillContentView** — Receives `isShowing` changes via `.onReceive` and drives `scale`/`opacity` state for spring appear (0.85→1.0, 0→1) / easeOut dismiss. Content animates between `WaveformView` and `ProgressView` on `isProcessing`.

**AppDelegate wiring** — `onRecordingStart`: show pill before mic permission check; `onRecordingStop`: `startProcessing()` then `runTranscription()`; all `runTranscription()` exit paths call `hide()`. Recording icon tinted purple (#6E56CF) via `button.contentTintColor`.

pbxproj additions: UI group `106`, fileRef PillWindow.swift `107`, buildFile `108`, fileRef WaveformView.swift `109`, buildFile `110`. Next available UUID: `000000000000000000000111`.

### Phase 8 — Settings Window ✅

**Files:** `Blurt/UI/SettingsView.swift`, updated `Blurt/Models/BlurtSettings.swift`, `Blurt/App/BlurtApp.swift`, `Blurt/App/AppDelegate.swift`

**SettingsView** — NavigationSplitView with 8 sidebar sections: General, Hotkey, Formality, Vocabulary, Voice Commands, App Profiles, Transcription, History. Window minimum size 680×460. Opened via `NSApp.sendAction(Selector("showSettingsWindow:"))` in `AppDelegate.openSettings()` (triggered by "Settings..." menu item, Cmd+,).

**BlurtApp.swift** — `Settings { SettingsView() }` replaces `EmptyView()`. SwiftUI handles the window lifecycle and Cmd+, shortcut automatically.

**BlurtSettings** additions:
- `modelSize: WhisperModelSize` (.base/.small/.medium) — stored in UserDefaults
- `alwaysShowPill: Bool` — whether pill stays on screen when not recording
- `enablePunctuation: Bool` — toggle punctuation (default on)
- `enableFillerRemoval: Bool` — toggle filler removal (default on)
- `customFillerWords: [String]` — user-added filler words
- `wordSubstitutions: [String]` — "from\tto" pairs for word replacement
- `launchAtLogin: Bool` — computed via `SMAppService.mainApp`

**Section breakdown:**
- **General** — Launch at login (SMAppService), always-show-pill toggle
- **Hotkey** — Shows current hotkey (Fn), accessibility + microphone permission status with deep-link buttons
- **Formality** — Segmented preset picker (Casual/Neutral/Formal), punctuation + filler removal toggles
- **Vocabulary** — Built-in filler word list display, custom filler word add/remove, word substitution pairs (tab-separated from→to)
- **Voice Commands / App Profiles** — Labeled placeholders with "coming soon"
- **Transcription** — Radio picker for Base/Small/Medium model with size/accuracy details
- **History** — Placeholder (storage infrastructure pending)

**Key fix:** `onChange(of:)` uses macOS 13-compatible single-arg form; `import AVFoundation` added for `AVCaptureDevice` permission check.

pbxproj additions: fileRef `000000000000000000000111` (SettingsView.swift), buildFile `000000000000000000000112`. Next available UUID: `000000000000000000000113`.

### Phase 9 — Polish ✅ (marketing site pending — not present locally)

**1. Menubar icons (AppDelegate.swift)**  
Static `NSImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .medium)` applied to all states for crisp rendering at all densities. Recording uses `.medium` weight + purple `#6E56CF` `contentTintColor`. Processing state drives a `Timer` at 0.45s intervals cycling `ellipsis → ellipsis.circle → ellipsis.circle.fill`, giving a native-feeling animation without any custom drawing.

**2. App icon (scripts/generate-icon.swift + Assets.xcassets/AppIcon.appiconset/)**  
Swift generator script creates all 10 required PNG sizes (16–512 @1x/@2x). Icon: deep indigo→purple diagonal gradient background, 7 rounded waveform bars in the brand gradient (#8B5CF6→#BFAEFF). Run `swift scripts/generate-icon.swift` to regenerate. Contents.json updated with all filenames.

**3. Onboarding flow (Blurt/UI/OnboardingView.swift)**  
`OnboardingWindowController.shared.showIfNeeded()` checks `blurt.onboardingComplete` in UserDefaults and shows a dark-themed 560×460 window on first launch. Four steps:
- **Welcome** — brand intro with three feature pills (Private / Instant / Offline)
- **Accessibility** — explains why access is needed, "Grant Access" calls `AXIsProcessTrustedWithOptions`, polls every 1s, auto-advances when granted
- **Microphone** — calls `AVCaptureDevice.requestAccess`, auto-advances when granted
- **Model download** — shows live progress bar from `Transcriber.shared.state` (polling every 0.5s), reveals "Start Using Blurt" button when state is `.ready`

Onboarding replaces the old `checkMicrophonePermission()` NSAlert.

**4. Error handling in pill (PillWindow.swift, WaveformView.swift, AppDelegate.swift)**  
`PillWindowController.pillState` replaces the `isProcessing: Bool` flag with an enum: `.recording`, `.processing`, `.error(String)`. `showError(_ message:, duration:)` shows a pill with an orange exclamation icon and message text, then auto-dismisses after `duration` seconds (default 2.5s). Error cases wired in AppDelegate:
- Mic not granted → "Mic access required"
- Model downloading → "Downloading model… X%"
- Model loading → "Loading model…"
- Transcription failed → "Transcription failed"

`WaveformView` updated to observe `$pillState` instead of `$isProcessing`.

**5. Marketing site (marketing-site/)** — Source code was not present anywhere on disk. Built from scratch as a Next.js 14 + Tailwind CSS + Framer Motion site at `marketing-site/` matching the CLAUDE.md spec. All components are in `components/blurt/` (not `components/voiceflow/`) — born Blurt, no rename needed.

Structure:
- `app/layout.tsx` — Title "Blurt — Hold. Speak. Done.", OG tags
- `app/page.tsx` — `BlurtPage` component assembling all sections
- `components/blurt/navigation.tsx` — Fixed nav, Mic logo, Download CTA
- `components/blurt/hero.tsx` — Animated waveform pill mockup, badge, headline, CTAs
- `components/blurt/social-proof.tsx` — 4 stat callouts (speed, local, 0 data, free)
- `components/blurt/how-it-works.tsx` — 3-step numbered cards
- `components/blurt/features.tsx` — 6-feature grid with icons
- `components/blurt/testimonials.tsx` — Masonry testimonial cards
- `components/blurt/download-cta.tsx` — Full-width download section with glow
- `components/blurt/footer.tsx` — Logo, links, copyright "© Blurt"

Design system: `tailwind.config.js` maps all CLAUDE.md brand tokens (background/foreground/primary/#6E56CF, card, muted-text, etc.). Custom waveform bar animation in Tailwind keyframes.

**Dev server:** `npm run dev` in `marketing-site/` → http://localhost:3000 (currently running)

pbxproj additions: fileRef OnboardingView.swift `000000000000000000000113`, buildFile `000000000000000000000114`. Next available UUID: `000000000000000000000115`.

### Phase 10 — Distribution ✅

**Release build:** `xcodebuild -configuration Release` → `build/Release/Blurt.app` (unsigned, macOS 13+)

**DMG:** `build/Blurt-v1.0.0.dmg` — created with `hdiutil`, compressed UDZO, app + Applications symlink layout, 698KB

**Git repository:** Initialized at project root. Nested `.git` in `Blurt/` source dir removed and re-flattened. `.gitignore` excludes `build/`, `DerivedData/`, `*.bin` (whisper models), `node_modules/`, `.next/`.

**GitHub:** [github.com/rocoladore-rgb/blurt](https://github.com/rocoladore-rgb/blurt) — initial commit "Blurt v1.0.0 — initial release" (69 files)

**GitHub Release:** Tagged `v1.0.0` — [github.com/rocoladore-rgb/blurt/releases/tag/v1.0.0](https://github.com/rocoladore-rgb/blurt/releases/tag/v1.0.0)

**DMG download URL:** `https://github.com/rocoladore-rgb/blurt/releases/download/v1.0.0/Blurt-v1.0.0.dmg`

**Marketing site:** Download buttons in `hero.tsx`, `download-cta.tsx`, and footer `GitHub` link all wired to live URLs. Committed and pushed.

**Remaining manual step:** Connect GitHub repo to Vercel + add custom domain (user handles this).

---

### v1.0.1 Patch Release

**Fixes applied:**
1. **Settings window** — `openSettings()` now creates and retains a strong `NSWindow` property on AppDelegate hosting `SettingsView`. Calls `makeKeyAndOrderFront` + `NSApp.activate(ignoringOtherApps: true)`. Added `import SwiftUI` to AppDelegate.
2. **Transcription speed** — Switched default model from `ggml-base.en.bin` to `ggml-tiny.en.bin` (39 MB vs 148 MB). Model pre-warmed on launch via existing `prepare()` call. Processing state shown immediately on Fn release (already wired in v1.0.0).
3. **Pill size** — Halved: 320×64 → 160×32 pt. Updated `positionAtBottomCenter` centering offset (−160 → −80). Reduced barCount 28→20, maxHeight 40→20. Scaled down error text (13→11 pt) and padding (16→10 pt). Spinner scaleEffect 0.75→0.55.
4. **Waveform reactivity** — Raw RMS amplified 8× (`min(1.0, amplitude * 8.0)`) before mapping to bar heights. Loud speech now fills bars to near-maximum.

**Build:** `build/Blurt-v1.0.1.dmg` (436 KB)

**GitHub Release:** [v1.0.1](https://github.com/rocoladore-rgb/blurt/releases/tag/v1.0.1)

**Download URL:** `https://github.com/rocoladore-rgb/blurt/releases/download/v1.0.1/Blurt-v1.0.1.dmg`

**Marketing site:** All three download buttons updated to v1.0.1 URL and pushed to GitHub.
