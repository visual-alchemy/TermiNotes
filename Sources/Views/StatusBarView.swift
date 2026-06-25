import SwiftUI

struct StatusBarView: View {
    let text: String
    let cursorPosition: Int
    
    private var lineAndColumn: (line: Int, column: Int) {
        let textPrefix = text.prefix(max(0, min(cursorPosition, text.count)))
        let lines = textPrefix.components(separatedBy: "\n")
        let line = lines.count
        let column = (lines.last?.count ?? 0) + 1
        return (line, column)
    }
    
    private var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }
    
    private var charCount: Int {
        text.count
    }
    
    var body: some View {
        HStack {
            let pos = lineAndColumn
            Text("Ln \(pos.line), Col \(pos.column)  |  \(wordCount) words  |  \(charCount) chars")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)))
    }
}
