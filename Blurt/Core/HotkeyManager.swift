import AppKit
import Carbon

// Monitors the Fn key (and optionally any other key) via a CGEvent tap.
// The Fn key fires .flagsChanged events with NX_SECONDARYFNMASK set.
// All other configurable hotkeys fire standard .keyDown / .keyUp events.
final class HotkeyManager {
    static let shared = HotkeyManager()

    var onRecordingStart: (() -> Void)?
    var onRecordingStop: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isFnKeyDown = false

    private init() {}

    func start() {
        guard AXIsProcessTrusted() else {
            requestAccessibilityPermission()
            return
        }
        installEventTap()
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let src = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func installEventTap() {
        let mask: CGEventMask =
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue)

        let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon!).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let tap else {
            print("Blurt: failed to create event tap — check Accessibility permission")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handleEvent(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        switch type {
        case .flagsChanged:
            let flags = event.flags
            let fnDown = flags.contains(.maskSecondaryFn)
            if fnDown && !isFnKeyDown {
                isFnKeyDown = true
                DispatchQueue.main.async { self.onRecordingStart?() }
            } else if !fnDown && isFnKeyDown {
                isFnKeyDown = false
                DispatchQueue.main.async { self.onRecordingStop?() }
            }
        default:
            break
        }
        return Unmanaged.passRetained(event)
    }

    private func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        AXIsProcessTrustedWithOptions(options)
    }
}
