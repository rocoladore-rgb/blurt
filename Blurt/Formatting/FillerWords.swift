import Foundation

enum FillerWords {
    // Multi-word phrases must come before their sub-phrases so they match first.
    // Sorted longest → shortest within each group.

    // Always removed regardless of surrounding context — these are never
    // used with a different meaning in normal spoken sentences.
    static let unconditional: [String] = [
        "you know what i mean",
        "you know",
        "i mean",
        "sort of",
        "kind of",
        "basically",
        "literally",
        "um",
        "uh",
    ]

    // Removed only when comma-delimited or at a sentence boundary — these
    // words have legitimate non-filler uses ("I like pizza", "turn right",
    // "I just got home") and must not be stripped from mid-sentence.
    static let contextual: [String] = [
        "actually",
        "right",
        "just",
        "like",
        "so",
    ]

    static var all: [String] { unconditional + contextual }
}
