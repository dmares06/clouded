import Foundation

struct BrainDump: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let rawText: String
    let structuredItems: [String]
    let createdAt: Date

    init(id: UUID = UUID(), title: String? = nil, rawText: String, structuredItems: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title ?? BrainDump.generateTitle(from: rawText)
        self.rawText = rawText
        self.structuredItems = structuredItems
        self.createdAt = createdAt
    }

    /// Generate a short title from the first few words of the raw text
    static func generateTitle(from text: String) -> String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = cleaned.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        let titleWords = Array(words.prefix(5))
        var title = titleWords.joined(separator: " ")
        if words.count > 5 { title += "..." }
        return title.isEmpty ? "Untitled" : title
    }

    /// Parse raw text into structured bullet points
    static func structure(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // Split on natural delimiters: periods, "and", "also", commas, newlines
        var items: [String] = []

        // First split by newlines
        let lines = trimmed.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for line in lines {
            // Split long lines by sentence endings or conjunctions
            let parts = splitBySentence(line)
            items.append(contentsOf: parts)
        }

        return items.map { cleanItem($0) }.filter { !$0.isEmpty }
    }

    private static func splitBySentence(_ text: String) -> [String] {
        // Split on period followed by space, " and then ", " also ", " plus "
        let pattern = #"(?<=\.)\s+|(?<=\!)\s+|\s+and then\s+|\s+also\s+|\s+plus\s+"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return [text]
        }

        let range = NSRange(text.startIndex..., in: text)
        var results: [String] = []
        var lastEnd = text.startIndex

        regex.enumerateMatches(in: text, range: range) { match, _, _ in
            guard let matchRange = match?.range, let swiftRange = Range(matchRange, in: text) else { return }
            let segment = String(text[lastEnd..<swiftRange.lowerBound])
            if !segment.trimmingCharacters(in: .whitespaces).isEmpty {
                results.append(segment)
            }
            lastEnd = swiftRange.upperBound
        }

        let remaining = String(text[lastEnd...])
        if !remaining.trimmingCharacters(in: .whitespaces).isEmpty {
            results.append(remaining)
        }

        return results.isEmpty ? [text] : results
    }

    private static func cleanItem(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove leading bullet chars
        cleaned = cleaned.replacingOccurrences(of: #"^[\-\•\*\d+\.]\s*"#, with: "", options: .regularExpression)
        // Capitalize first letter
        if let first = cleaned.first {
            cleaned = String(first).uppercased() + String(cleaned.dropFirst())
        }
        // Remove trailing period
        if cleaned.hasSuffix(".") { cleaned = String(cleaned.dropLast()) }
        return cleaned
    }
}
