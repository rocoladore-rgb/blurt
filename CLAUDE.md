# Blurt — Claude Code Project Brief

> Drop this file in the root of your Blurt project folder. Claude Code reads it automatically at the start of every session, giving it full context without you needing to re-explain anything.

---

## What Is Blurt?

Blurt is a macOS menubar app that lets you dictate text into any app by holding a hotkey. It transcribes your voice locally using whisper.cpp, removes filler words, and types the cleaned-up text directly into whatever app you're focused on. Think Whisperflow — but with smarter text reformatting.

**Tagline:** Hold. Speak. Done.

---

## Repository Structure (Target)

```
blurt/
├── CLAUDE.md                        ← you are here
├── SPEC.md                          ← full product spec (see below)
├── Blurt.xcodeproj/                 ← Xcode project
├── Blurt/
│   ├── App/
│   │   ├── BlurtApp.swift           ← @main entry point, NSApplicationDelegate
│   │   └── AppDelegate.swift        ← menubar setup, lifecycle
│   ├── Core/
│   │   ├── HotkeyManager.swift      ← global CGEvent hotkey detection
│   │   ├── AudioRecorder.swift      ← AVFoundation mic capture
│   │   ├── Transcriber.swift        ← whisper.cpp bridge
│   │   └── TextInserter.swift       ← CGEvent keyboard simulation
│   ├── Formatting/
│   │   ├── FormattingEngine.swift   ← filler word removal + formality
│   │   └── FillerWords.swift        ← filler word list
│   ├── UI/
│   │   ├── PillWindow.swift         ← floating waveform pill (NSPanel)
│   │   ├── WaveformView.swift       ← live audio waveform (SwiftUI)
│   │   └── SettingsView.swift       ← settings window (SwiftUI)
│   ├── Models/
│   │   └── BlurtSettings.swift      ← @AppStorage user preferences
│   └── Resources/
│       ├── Assets.xcassets
│       └── ggml-base.en.bin         ← whisper model (downloaded on first launch)
├── BlurtTests/
└── marketing-site/                  ← Next.js marketing website (see below)
    └── [voiceflow site renamed to Blurt]
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI + AppKit (hybrid) |
| Transcription | whisper.cpp (via Swift C interop) |
| Audio | AVFoundation |
| Hotkey | CGEvent tap (global, works in any app) |
| Text insertion | CGEvent keyboard simulation |
| Settings persistence | @AppStorage / UserDefaults |
| Menubar | NSStatusItem + NSMenu |
| Floating pill | NSPanel (non-activating, always-on-top) |
| Marketing site | Next.js 14, Tailwind CSS, Framer Motion, shadcn/ui |
| Hosting | Vercel |

---

## Core Features (MVP)

### 1. Global Hotkey
- Default key: `Fn` (configurable to any key or combo)
- Press and hold → starts recording
- Release → stops recording, triggers transcription + insertion
- Uses CGEvent tap — works in ANY app, no focus required

### 2. Local Transcription (whisper.cpp)
- Runs 100% on-device, no API, no internet required, completely free
- Ships with `ggml-base.en` model (~150MB) — fast and accurate
- User can switch to `ggml-small` or `ggml-medium` in settings for better accuracy
- Heavily optimised for Apple Silicon (M1/M2/M3) via Metal GPU acceleration
- First launch: downloads model file automatically with a progress indicator

### 3. Text Formatting Engine
Three formality presets, all customisable after selection:

| Level | Behaviour |
|---|---|
| **Formal** | Full punctuation, no contractions, corrects grammar, removes all filler |
| **Neutral** | Natural punctuation, light cleanup, sounds like a real person |
| **Casual** | Keeps contractions, relaxed punctuation, only removes filler words |

Filler words removed in all modes: *um, uh, like, you know, sort of, kind of, basically, literally, right, so, actually, just, I mean, you know what I mean*

Customisable per-mode:
- Toggle punctuation (commas, full stops, question marks)
- Toggle filler word removal
- Add/remove words from the filler list
- Custom word substitutions (e.g. "gonna → going to")

### 4. Floating Pill UI
- Appears at the bottom-centre of the screen when recording starts
- Disappears when recording stops (default behaviour)
- Shows a live animated waveform that reacts to voice volume (louder = taller bars)
- Pill is an `NSPanel` set to non-activating and always-on-top
- Smooth spring animation on appear/disappear
- **Always-visible mode**: optional setting to keep pill on screen at all times

### 5. Menubar Icon
- Lives in the macOS menubar (NSStatusItem)
- Icon changes state: idle → recording → processing
- Click → opens settings window
- Right-click menu: Settings, Formality selector, Quit

### 6. Settings Window (SwiftUI)
- Hotkey picker (press any key to assign)
- Formality level selector (Formal / Neutral / Casual) + expand for custom rules
- Pill behaviour toggle (show only when recording vs always visible)
- Whisper model selector (Base / Small / Medium — tradeoff: speed vs accuracy)
- Custom vocabulary / substitution rules
- Launch at login toggle
- Microphone permission status

---

## Floating Pill — Detailed Spec

```
┌─────────────────────────────────┐
│  ▁▃▅▇▅▃▁▃▅▇▅▃▁▃▅▇▅▃▁▃▅▃▁      │  ← waveform, bars react to volume
└─────────────────────────────────┘
        bottom-centre of screen
```

- **Shape:** Rounded pill / capsule, ~320px wide, ~56px tall
- **Background:** Dark frosted glass (`NSVisualEffectView`, `.dark` material)
- **Waveform bars:** Gradient from `#6E56CF` → `#8B5CF6`, ~24 bars, 2px wide, 2px gap
- **Animation:** Each bar animates height based on real microphone amplitude
- **Position:** Centred horizontally, ~40px from bottom of screen
- **Window level:** `NSWindow.Level.floating` (above all other windows)
- **Appears with:** Spring animation, scale 0.8 → 1.0, opacity 0 → 1, duration 0.25s
- **Disappears with:** Fade out + scale 1.0 → 0.9, duration 0.2s

---

## Design System (matches marketing site)

Use these exact values throughout the macOS app UI for brand consistency:

```swift
// Colors
let background = Color(hex: "#000000")
let foreground = Color(hex: "#F5F5F7")
let primary = Color(hex: "#6E56CF")       // purple accent — all interactive elements
let primaryDark = Color(hex: "#5B45B0")
let card = Color(hex: "#111111")
let cardElevated = Color(hex: "#161616")
let surface = Color(hex: "#0A0A0A")
let mutedText = Color(hex: "#A1A1A6")
let tertiaryText = Color(hex: "#6E6E73")
let border = Color.white.opacity(0.08)

// Typography
// Use SF Pro (system font) — matches Apple aesthetic
// Headings: .bold, tracking: -0.02em
// Body: .regular, leading: relaxed

// Corner radius
let radiusDefault: CGFloat = 12
let radiusPill: CGFloat = 100

// Waveform gradient
// from: #6E56CF (bottom), to: #8B5CF6 (top)
```

---

## Marketing Website — Rename Brief

The marketing site lives in `marketing-site/` (currently named `voice-flow-marketing-website`). It was built in Next.js and is deployed on Vercel. It needs to be renamed from VoiceFlow → Blurt throughout.

### Files to update:

| File | Changes |
|---|---|
| `app/layout.tsx` | title, description, OG tags: "VoiceFlow" → "Blurt". New tagline: "Hold. Speak. Done." |
| `app/page.tsx` | rename `VoiceFlowPage` → `BlurtPage` |
| `components/voiceflow/navigation.tsx` | Logo text "VoiceFlow" → "Blurt". Keep Mic icon. |
| `components/voiceflow/hero.tsx` | "VoiceFlow silently listens" → "Blurt listens". All "VoiceFlow" → "Blurt". Update window chrome title. |
| `components/voiceflow/how-it-works.tsx` | "VoiceFlow handles punctuation" → "Blurt handles punctuation" |
| `components/voiceflow/features.tsx` | All "VoiceFlow" → "Blurt" in copy |
| `components/voiceflow/download-cta.tsx` | "Download VoiceFlow — Free for Mac" → "Download Blurt — Free for Mac" |
| `components/voiceflow/footer.tsx` | Logo "VoiceFlow" → "Blurt". Copyright "© VoiceFlow" → "© Blurt" |
| `components/voiceflow/testimonials.tsx` | Update quotes to reference "Blurt" not "VoiceFlow" |
| `components/voiceflow/social-proof.tsx` | Any "VoiceFlow" refs |

### Folder rename:
- `components/voiceflow/` → `components/blurt/` (update all imports)

### Keep everything else:
- Full design system (colors, typography, animations) stays identical
- All Framer Motion animations unchanged
- Waveform component unchanged — it's perfect for the pill UI reference too
- Pricing tiers, feature list, stats — keep for now (placeholder until launch)

---

## Build Order (Recommended)

Work through these phases in order. Each builds on the last.

### Phase 1 — Project Scaffold
- [ ] Create new macOS app in Xcode (target: macOS 13+, Swift, SwiftUI)
- [ ] Set up folder structure as above
- [ ] Configure `Info.plist`: microphone permission string, login item, no dock icon (`LSUIElement = YES`)
- [ ] Set up basic `NSStatusItem` in menubar with placeholder icon
- [ ] Confirm app runs and shows in menubar

### Phase 2 — Global Hotkey
- [ ] Implement `CGEvent` tap for global key detection
- [ ] Detect `Fn` key press and release (keycode: `63`)
- [ ] Add accessibility permission request + check on launch
- [ ] Test: holding Fn in any app triggers the handler

### Phase 3 — Audio Recording
- [ ] `AVAudioEngine` setup for microphone capture
- [ ] Request + check microphone permission
- [ ] Capture raw PCM audio while hotkey held
- [ ] Buffer audio in memory (not written to disk)
- [ ] Expose amplitude level for waveform animation (RMS value per buffer)

### Phase 4 — whisper.cpp Integration
- [ ] Add whisper.cpp as a Swift Package or via bridging header
- [ ] Download `ggml-base.en.bin` on first launch (with progress bar)
- [ ] `Transcriber.swift`: takes raw PCM buffer → returns `String`
- [ ] Run transcription off main thread
- [ ] Test: speak a sentence, get text back

### Phase 5 — Text Insertion
- [ ] `TextInserter.swift`: takes a `String`, simulates keyboard input via `CGEvent`
- [ ] Handle special characters properly
- [ ] Test: text appears in TextEdit, Slack, browser URL bar, Terminal

### Phase 6 — Formatting Engine
- [ ] `FormattingEngine.swift`: takes raw transcript → returns cleaned string
- [ ] Implement filler word removal (see list above)
- [ ] Implement 3 formality presets (Formal / Neutral / Casual)
- [ ] Load user settings from `@AppStorage`
- [ ] Test with sample inputs

### Phase 7 — Floating Pill UI
- [ ] Create `NSPanel` subclass (non-activating, borderless, floating level)
- [ ] Position at bottom-centre of main screen
- [ ] `WaveformView.swift`: SwiftUI view with animated bars driven by amplitude
- [ ] Wire amplitude from `AudioRecorder` → `WaveformView` via Combine / `@Published`
- [ ] Show on keydown, hide on keyup with spring animations
- [ ] Implement always-visible mode toggle

### Phase 8 — Settings UI
- [ ] `SettingsView.swift`: SwiftUI settings window
- [ ] Hotkey picker component
- [ ] Formality selector (Formal / Neutral / Casual + expand for custom)
- [ ] Punctuation toggles
- [ ] Filler word list editor
- [ ] Custom substitution rules (e.g. "gonna → going to")
- [ ] Model selector (Base / Small / Medium)
- [ ] Pill visibility toggle
- [ ] Launch at login toggle

### Phase 9 — Polish
- [ ] Custom menubar icon (idle / recording / processing states)
- [ ] App icon
- [ ] Onboarding flow (first launch: permission requests, model download)
- [ ] Error handling (no mic permission, model missing, transcription failed)
- [ ] Rename marketing site VoiceFlow → Blurt

### Phase 10 — Distribution
- [ ] Code sign with Developer ID
- [ ] Notarise with Apple
- [ ] Package as `.dmg`
- [ ] Update marketing site download link
- [ ] Submit to marketing site

---

## Key Technical Notes

### CGEvent tap for Fn key
The `Fn` key is special on macOS — it's a modifier key and requires `CGEventFlags` monitoring, not a standard keycode listener. Use `CGEventTap` with `CGEventMaskBit(.flagsChanged)` and check for `NX_SECONDARYFNMASK`.

### whisper.cpp in Swift
Use the Swift Package Manager wrapper: `github.com/ggergansen/whisper.spm` or bridge directly via a C interop header. Audio must be converted to 16kHz mono Float32 PCM before passing to whisper.

### Text insertion via CGEvent
```swift
func typeString(_ text: String) {
    let source = CGEventSource(stateID: .hidSystemState)
    for char in text.unicodeScalars {
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        keyDown?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [UniChar(char.value)])
        keyUp?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [UniChar(char.value)])
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
```

### Required entitlements (Xcode)
```xml
<key>com.apple.security.device.audio-input</key>       <!-- microphone -->
<key>com.apple.security.automation.apple-events</key>  <!-- text insertion -->
<key>com.apple.security.temporary-exception.mach-lookup.global-name</key>
```

### Info.plist keys
```xml
<key>LSUIElement</key><true/>                          <!-- no dock icon -->
<key>NSMicrophoneUsageDescription</key>
<string>Blurt needs microphone access to transcribe your voice.</string>
<key>NSAppleEventsUsageDescription</key>
<string>Blurt needs accessibility access to type into other apps.</string>
```

---

## Decisions Already Made (Do Not Re-Ask)

| Decision | Choice |
|---|---|
| App name | **Blurt** |
| Transcription engine | **whisper.cpp (local, free, offline)** |
| Formality levels | **Formal / Neutral / Casual** |
| Output method | **Type directly into focused app (CGEvent)** |
| Pill visibility default | **Only show while recording (disappears on key release)** |
| Pill style | **Floating bottom-centre, waveform reacts to voice volume** |
| macOS minimum | **macOS 13 Ventura** |
| Dock icon | **Hidden (menubar-only app)** |

---

## Current Status

- [x] Product spec finalised
- [x] Design system defined (from marketing site)
- [x] Marketing site built (Next.js, Vercel) — needs rename VoiceFlow → Blurt
- [ ] Xcode project created
- [ ] Any code written

**Start here:** Phase 1 — create the Xcode project scaffold.

---

## Questions / Clarifications to Raise With the User

If you're unsure about anything not covered here, ask the user. Do not make up decisions for:
- Pricing model (free? freemium? one-time?)
- App Store vs direct distribution
- Whether to support Intel Macs (or Apple Silicon only)
- Specific icon / branding assets

Everything else in this doc is decided — proceed confidently.
