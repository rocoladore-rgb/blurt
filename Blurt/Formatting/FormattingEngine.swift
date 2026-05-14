import Foundation

final class FormattingEngine {
    static let shared = FormattingEngine()
    private init() {}

    /// Cleans `rawText` according to the active `BlurtSettings.preset`.
    /// Returns the original string unchanged if it is empty.
    func format(_ rawText: String) -> String {
        guard !rawText.isEmpty else { return rawText }
        var text = rawText

        switch BlurtSettings.shared.preset {
        case .casual:
            text = removeFillers(text)
            text = cleanArtifacts(text)

        case .neutral:
            text = removeFillers(text)
            text = cleanArtifacts(text)
            text = ensureTerminalPunctuation(text)
            text = capitalizeSentences(text)

        case .formal:
            text = removeFillers(text)
            text = expandContractions(text)
            text = cleanArtifacts(text)
            text = ensureTerminalPunctuation(text)
            text = capitalizeSentences(text)
        }

        return text
    }

    // MARK: - Filler removal

    private func removeFillers(_ text: String) -> String {
        var s = text
        for filler in FillerWords.unconditional {
            s = removeGlobally(filler, from: s)
        }
        for filler in FillerWords.contextual {
            s = removeContextual(filler, from: s)
        }
        return s
    }

    /// Removes `filler` wherever it appears at a word boundary: start, middle, or end.
    /// Safe for unambiguous fillers that are never legitimate vocabulary words.
    private func removeGlobally(_ filler: String, from text: String) -> String {
        var s = text
        let f = NSRegularExpression.escapedPattern(for: filler)
        let patterns = [
            "(?i)^\\b\(f)\\b[,]?\\s+",                    // "Um, sentence" / "Um sentence"
            "(?i),\\s*\\b\(f)\\b[,]?(?=\\s|[.!?]|$)",    // ", filler," / ", filler."
            "(?i)\\s+\\b\(f)\\b[,]?(?=\\s|[.!?]|$)",     // " filler " / " filler."
        ]
        for pattern in patterns {
            s = s.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        return s
    }

    /// Removes `filler` only at sentence edges or between commas.
    /// Guards against false positives for words like "like", "just", "right".
    private func removeContextual(_ filler: String, from text: String) -> String {
        var s = text
        let f = NSRegularExpression.escapedPattern(for: filler)
        let patterns = [
            "(?i)^\\b\(f)\\b,\\s+",                       // "So, I was…"  (must have comma)
            "(?i),\\s*\\b\(f)\\b[,]?(?=\\s|[.!?]|$)",    // ", like," / ", right."
            "(?i)\\s+\\b\(f)\\b(?=\\s*[.!?]$)",           // "…you know." at very end
        ]
        for pattern in patterns {
            s = s.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        return s
    }

    // MARK: - Contraction expansion (Formal mode)

    private static let contractions: [(pattern: String, replacement: String)] = [
        ("\\bwon't\\b",     "will not"),
        ("\\bcan't\\b",     "cannot"),
        ("\\bdon't\\b",     "do not"),
        ("\\bdoesn't\\b",   "does not"),
        ("\\bdidn't\\b",    "did not"),
        ("\\bisn't\\b",     "is not"),
        ("\\baren't\\b",    "are not"),
        ("\\bwasn't\\b",    "was not"),
        ("\\bweren't\\b",   "were not"),
        ("\\bhaven't\\b",   "have not"),
        ("\\bhasn't\\b",    "has not"),
        ("\\bhadn't\\b",    "had not"),
        ("\\bwouldn't\\b",  "would not"),
        ("\\bcouldn't\\b",  "could not"),
        ("\\bshouldn't\\b", "should not"),
        ("\\bI'm\\b",       "I am"),
        ("\\bI've\\b",      "I have"),
        ("\\bI'll\\b",      "I will"),
        ("\\bI'd\\b",       "I would"),
        ("\\byou're\\b",    "you are"),
        ("\\bthey're\\b",   "they are"),
        ("\\bwe're\\b",     "we are"),
        ("\\bhe's\\b",      "he is"),
        ("\\bshe's\\b",     "she is"),
        ("\\bit's\\b",      "it is"),
        ("\\bthat's\\b",    "that is"),
        ("\\bthere's\\b",   "there is"),
        ("\\bhere's\\b",    "here is"),
        ("\\blet's\\b",     "let us"),
    ]

    private func expandContractions(_ text: String) -> String {
        var s = text
        for (pattern, replacement) in Self.contractions {
            s = s.replacingOccurrences(
                of: pattern, with: replacement,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        return s
    }

    // MARK: - Punctuation

    private func ensureTerminalPunctuation(_ text: String) -> String {
        let s = text.trimmingCharacters(in: .whitespaces)
        guard let last = s.last, !".!?".contains(last) else { return text }
        return s + "."
    }

    // MARK: - Capitalisation

    private func capitalizeSentences(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        var chars = Array(text)

        // Capitalise the first non-whitespace character.
        if let i = chars.indices.first(where: { !chars[$0].isWhitespace }) {
            chars[i] = Character(chars[i].uppercased())
        }

        // Capitalise the character that follows terminal punctuation + whitespace.
        var afterTerminal = false
        for i in chars.indices {
            if afterTerminal && chars[i].isLetter {
                chars[i] = Character(chars[i].uppercased())
                afterTerminal = false
            }
            if ".!?".contains(chars[i]) {
                afterTerminal = true
            } else if !chars[i].isWhitespace {
                afterTerminal = false
            }
        }

        return String(chars)
    }

    // MARK: - Whitespace / artifact cleanup

    private func cleanArtifacts(_ text: String) -> String {
        var s = text
        s = s.replacingOccurrences(of: #"\s{2,}"#,   with: " ",  options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s*,\s*,"#, with: ",",  options: .regularExpression)
        s = s.replacingOccurrences(of: #"\s+([.,!?])"#, with: "$1", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
