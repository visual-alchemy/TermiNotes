import AppKit

class MarkdownHighlighter: NSObject, NSTextStorageDelegate {
    
    private let baseFont: NSFont
    private let baseColor: NSColor
    
    // Precompiled regex patterns
    private static let codeBlockPattern = try! NSRegularExpression(pattern: "^```[\\s\\S]*?^```", options: [.anchorsMatchLines, .dotMatchesLineSeparators])
    private static let h1Pattern = try! NSRegularExpression(pattern: "^# .+$", options: .anchorsMatchLines)
    private static let h2Pattern = try! NSRegularExpression(pattern: "^## .+$", options: .anchorsMatchLines)
    private static let h3Pattern = try! NSRegularExpression(pattern: "^#{3,6} .+$", options: .anchorsMatchLines)
    private static let boldPattern = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*", options: [])
    private static let italicPattern = try! NSRegularExpression(pattern: "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", options: [])
    private static let inlineCodePattern = try! NSRegularExpression(pattern: "`([^`]+)`", options: [])
    private static let listPattern = try! NSRegularExpression(pattern: "^(\\s*[-*+] )", options: .anchorsMatchLines)
    private static let blockquotePattern = try! NSRegularExpression(pattern: "^>.+$", options: .anchorsMatchLines)
    private static let linkPattern = try! NSRegularExpression(pattern: "\\[([^\\]]+)\\]\\(([^)]+)\\)", options: [])
    private static let hrPattern = try! NSRegularExpression(pattern: "^(---+|\\*\\*\\*+)$", options: .anchorsMatchLines)
    
    // Colors
    private let greenAccent = NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)
    private let codeBackground = NSColor(red: 0.14, green: 0.17, blue: 0.21, alpha: 1.0)
    private let dimmedGray = NSColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
    private let linkBlue = NSColor(red: 0.36, green: 0.67, blue: 0.92, alpha: 1.0)
    
    init(font: NSFont, color: NSColor) {
        self.baseFont = font
        self.baseColor = color
        super.init()
    }
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        guard editedMask.contains(.editedCharacters) else { return }
        
        let text = textStorage.string as NSString
        let paragraphRange = text.lineRange(for: editedRange)
        let fullRange = NSRange(location: 0, length: textStorage.length)
        let textString = textStorage.string
        
        // Reset only the edited paragraph range to base style to avoid full-document layout invalidations
        textStorage.addAttributes([
            .font: baseFont,
            .foregroundColor: baseColor
        ], range: paragraphRange)
        
        // Code blocks are multi-line: search globally but only write inside paragraphRange
        applyCodeBlocks(storage: textStorage, text: textString, searchRange: fullRange, writeRange: paragraphRange)
        
        // Inline formatting rules are applied only inside the edited paragraph range
        applyHeaders(textStorage, text: textString, range: paragraphRange)
        applyBold(textStorage, text: textString, range: paragraphRange)
        applyItalic(textStorage, text: textString, range: paragraphRange)
        applyInlineCode(textStorage, text: textString, range: paragraphRange)
        applyLists(textStorage, text: textString, range: paragraphRange)
        applyBlockquotes(textStorage, text: textString, range: paragraphRange)
        applyLinks(textStorage, text: textString, range: paragraphRange)
        applyHorizontalRules(textStorage, text: textString, range: paragraphRange)
    }
    
    func applyFullHighlighting(to textStorage: NSTextStorage) {
        let fullRange = NSRange(location: 0, length: textStorage.length)
        let text = textStorage.string
        
        textStorage.addAttributes([
            .font: baseFont,
            .foregroundColor: baseColor
        ], range: fullRange)
        
        applyCodeBlocks(storage: textStorage, text: text, searchRange: fullRange, writeRange: fullRange)
        applyHeaders(textStorage, text: text, range: fullRange)
        applyBold(textStorage, text: text, range: fullRange)
        applyItalic(textStorage, text: text, range: fullRange)
        applyInlineCode(textStorage, text: text, range: fullRange)
        applyLists(textStorage, text: text, range: fullRange)
        applyBlockquotes(textStorage, text: text, range: fullRange)
        applyLinks(textStorage, text: text, range: fullRange)
        applyHorizontalRules(textStorage, text: text, range: fullRange)
    }
    
    // MARK: - Pattern Applicators
    
    private func applyCodeBlocks(storage: NSTextStorage, text: String, searchRange: NSRange, writeRange: NSRange) {
        Self.codeBlockPattern.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
            guard let matchRange = match?.range else { return }
            let intersection = NSIntersectionRange(matchRange, writeRange)
            if intersection.length > 0 {
                storage.addAttributes([
                    .backgroundColor: codeBackground,
                    .foregroundColor: NSColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1.0)
                ], range: intersection)
            }
        }
    }
    
    private func applyHeaders(_ storage: NSTextStorage, text: String, range: NSRange) {
        let boldFont = NSFontManager.shared.convert(baseFont, toHaveTrait: .boldFontMask)
        
        // H1 — larger
        let h1Font: NSFont
        if let sized = NSFont(name: baseFont.fontName, size: 16) {
            h1Font = NSFontManager.shared.convert(sized, toHaveTrait: .boldFontMask)
        } else {
            h1Font = boldFont
        }
        
        Self.h1Pattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttributes([
                .font: h1Font,
                .foregroundColor: greenAccent
            ], range: matchRange)
        }
        
        // H2 — slightly larger
        let h2Font: NSFont
        if let sized = NSFont(name: baseFont.fontName, size: 15) {
            h2Font = NSFontManager.shared.convert(sized, toHaveTrait: .boldFontMask)
        } else {
            h2Font = boldFont
        }
        
        Self.h2Pattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttributes([
                .font: h2Font,
                .foregroundColor: greenAccent
            ], range: matchRange)
        }
        
        // H3+ — bold, same size
        Self.h3Pattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttributes([
                .font: boldFont,
                .foregroundColor: greenAccent
            ], range: matchRange)
        }
    }
    
    private func applyBold(_ storage: NSTextStorage, text: String, range: NSRange) {
        let boldFont = NSFontManager.shared.convert(baseFont, toHaveTrait: .boldFontMask)
        Self.boldPattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttribute(.font, value: boldFont, range: matchRange)
        }
    }
    
    private func applyItalic(_ storage: NSTextStorage, text: String, range: NSRange) {
        let italicFont = NSFontManager.shared.convert(baseFont, toHaveTrait: .italicFontMask)
        Self.italicPattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttribute(.font, value: italicFont, range: matchRange)
        }
    }
    
    private func applyInlineCode(_ storage: NSTextStorage, text: String, range: NSRange) {
        Self.inlineCodePattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttribute(.backgroundColor, value: codeBackground, range: matchRange)
        }
    }
    
    private func applyLists(_ storage: NSTextStorage, text: String, range: NSRange) {
        Self.listPattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let bulletRange = match?.range(at: 1) else { return }
            storage.addAttribute(.foregroundColor, value: greenAccent, range: bulletRange)
        }
    }
    
    private func applyBlockquotes(_ storage: NSTextStorage, text: String, range: NSRange) {
        Self.blockquotePattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttribute(.foregroundColor, value: dimmedGray, range: matchRange)
        }
    }
    
    private func applyLinks(_ storage: NSTextStorage, text: String, range: NSRange) {
        Self.linkPattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let fullRange = match?.range,
                  let textRange = match?.range(at: 1) else { return }
            // Dim the whole link syntax
            storage.addAttribute(.foregroundColor, value: self.dimmedGray, range: fullRange)
            // Blue underline on the text portion
            storage.addAttributes([
                .foregroundColor: self.linkBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: textRange)
        }
    }
    
    private func applyHorizontalRules(_ storage: NSTextStorage, text: String, range: NSRange) {
        Self.hrPattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            storage.addAttribute(.foregroundColor, value: dimmedGray, range: matchRange)
        }
    }
}
