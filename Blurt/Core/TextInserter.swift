import AppKit

final class TextInserter {
    static let shared = TextInserter()
    private init() {}

    /// Types `text` into the currently focused app via CGEvent keyboard simulation.
    /// Must be called on the main thread. Silently no-ops on empty input.
    func insert(_ text: String) {
        guard !text.isEmpty else { return }

        let source = CGEventSource(stateID: .hidSystemState)

        for scalar in text.unicodeScalars {
            // Encode each Unicode scalar as one or two UTF-16 code units.
            var units: [UniChar]
            if scalar.value <= 0xFFFF {
                units = [UniChar(scalar.value)]
            } else {
                // Surrogate pair for code points above U+FFFF
                let v = scalar.value - 0x10000
                units = [UniChar(0xD800 + (v >> 10)), UniChar(0xDC00 + (v & 0x3FF))]
            }

            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
            let keyUp   = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)

            keyDown?.keyboardSetUnicodeString(stringLength: units.count, unicodeString: units)
            keyUp?.keyboardSetUnicodeString(stringLength: units.count,   unicodeString: units)

            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
}
