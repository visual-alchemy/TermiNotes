import SwiftUI
import AppKit

struct NSTextViewWrapper: NSViewRepresentable {
    @Binding var text: String
    @Binding var cursorPosition: Int
    var showLineNumbers: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = true
        
        let contentSize = scrollView.contentSize
        
        let textView = EditorTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        textView.autoresizingMask = [.width, .height]
        textView.isSelectable = true
        textView.isEditable = true
        textView.isRichText = false
        textView.importsGraphics = false
        
        // Terminal Styling (Dark Theme)
        textView.backgroundColor = NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)
        textView.textColor = NSColor(red: 0.83, green: 0.83, blue: 0.85, alpha: 1.0)
        textView.insertionPointColor = NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)
        
        // Monospace Font
        let font = NSFont(name: "Menlo", size: 13.0) ?? NSFont(name: "SF Mono", size: 13.0) ?? NSFont.userFixedPitchFont(ofSize: 13.0)!
        textView.font = font
        
        // Gutter Padding
        textView.textContainerInset = NSSize(width: showLineNumbers ? 56 : 16, height: 16)
        textView.showLineNumbers = showLineNumbers
        
        // Monospace code-friendly settings
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        textView.delegate = context.coordinator
        
        // Set up Markdown highlighter
        let highlighter = MarkdownHighlighter(
            font: font,
            color: NSColor(red: 0.83, green: 0.83, blue: 0.85, alpha: 1.0)
        )
        context.coordinator.highlighter = highlighter
        textView.textStorage?.delegate = highlighter
        
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.parent = self
        guard let textView = nsView.documentView as? EditorTextView else { return }
        
        // Only update text view if the change originated from the outside (not from user typing)
        if context.coordinator.lastProcessedText != text {
            context.coordinator.lastProcessedText = text
            
            let normalizedTextViewString = textView.string
                .replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\r", with: "\n")
            let normalizedText = text
                .replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\r", with: "\n")
            
            if normalizedTextViewString != normalizedText {
                let selectedRanges = textView.selectedRanges
                textView.string = text
                if !selectedRanges.isEmpty {
                    textView.selectedRanges = selectedRanges
                }
                // Re-apply full highlighting when note changes
                context.coordinator.highlighter?.applyFullHighlighting(to: textView.textStorage!)
            }
        }
        
        // Toggle line numbers
        if textView.showLineNumbers != showLineNumbers {
            textView.showLineNumbers = showLineNumbers
            textView.textContainerInset = NSSize(width: showLineNumbers ? 56 : 16, height: 16)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NSTextViewWrapper
        var highlighter: MarkdownHighlighter?
        var lastProcessedText: String?
        
        init(_ parent: NSTextViewWrapper) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? EditorTextView else { return }
            lastProcessedText = textView.string
            parent.text = textView.string
            textView.needsDisplay = true
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? EditorTextView else { return }
            let cursorLocation = textView.selectedRange().location
            DispatchQueue.main.async {
                self.parent.cursorPosition = cursorLocation
            }
            textView.needsDisplay = true
        }
    }
}

class EditorTextView: NSTextView {
    var showLineNumbers = true {
        didSet {
            needsDisplay = true
        }
    }
    
    override func drawBackground(in rect: NSRect) {
        super.drawBackground(in: rect)
        
        guard showLineNumbers,
              let layoutManager = layoutManager,
              let textContainer = textContainer else { return }
        
        // Save graphics state
        NSGraphicsContext.current?.saveGraphicsState()
        
        // Draw gutter background matching theme
        let gutterRect = NSRect(x: rect.origin.x, y: rect.origin.y, width: 40, height: rect.height)
        let gutterColor = NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)
        gutterColor.setFill()
        gutterRect.fill()
        
        // Draw separator border line
        let separatorColor = NSColor(red: 0.16, green: 0.20, blue: 0.25, alpha: 1.0)
        separatorColor.setStroke()
        let path = NSBezierPath()
        path.move(to: NSPoint(x: rect.origin.x + 40, y: rect.origin.y))
        path.line(to: NSPoint(x: rect.origin.x + 40, y: rect.origin.y + rect.height))
        path.lineWidth = 1
        path.stroke()
        
        // Determine layout metrics
        let visibleRect = rect
        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let visibleCharRange = layoutManager.characterRange(forGlyphRange: visibleGlyphRange, actualGlyphRange: nil)
        
        let text = self.string as NSString
        let inset = self.textContainerInset
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Menlo", size: 10) ?? NSFont.monospacedSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0)
        ]
        let activeAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Menlo", size: 10) ?? NSFont.monospacedSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor.white
        ]
        
        // Determine current cursor line safely
        let selectedRange = self.selectedRange()
        let safeCursorLocation = min(selectedRange.location, text.length)
        let textUpToCursor = text.substring(to: safeCursorLocation)
        let currentLine = textUpToCursor.components(separatedBy: "\n").count
        
        var lineNumber = 1
        let safeVisibleLocation = min(visibleCharRange.location, text.length)
        let preVisibleText = text.substring(to: safeVisibleLocation)
        lineNumber = preVisibleText.components(separatedBy: "\n").count
        
        var charIndex = visibleCharRange.location
        while charIndex < NSMaxRange(visibleCharRange) && charIndex < text.length {
            let lineRange = text.lineRange(for: NSRange(location: charIndex, length: 0))
            guard lineRange.length > 0 else { break }
            
            let startGlyphIndex = layoutManager.glyphIndexForCharacter(at: lineRange.location)
            var lineRect: NSRect
            if startGlyphIndex < layoutManager.numberOfGlyphs {
                lineRect = layoutManager.lineFragmentRect(forGlyphAt: startGlyphIndex, effectiveRange: nil, withoutAdditionalLayout: true)
            } else {
                lineRect = layoutManager.extraLineFragmentRect
                if lineRect.width == 0 || lineRect.height == 0 {
                    let glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
                    lineRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                }
            }
            
            // Calculate visual y position within text view coordinates
            let yPosition = lineRect.origin.y + inset.height
            
            let lineStr = "\(lineNumber)" as NSString
            let attrs = (lineNumber == currentLine) ? activeAttrs : normalAttrs
            let strSize = lineStr.size(withAttributes: attrs)
            let drawPoint = NSPoint(
                x: rect.origin.x + 40 - strSize.width - 8,
                y: yPosition + (lineRect.height - strSize.height) / 2
            )
            lineStr.draw(at: drawPoint, withAttributes: attrs)
            
            lineNumber += 1
            charIndex = NSMaxRange(lineRange)
        }
        
        NSGraphicsContext.current?.restoreGraphicsState()
    }
}
