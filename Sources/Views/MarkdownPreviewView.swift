import SwiftUI
import WebKit
import Ink

struct MarkdownPreviewView: NSViewRepresentable {
    var markdown: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Make background transparent so that the parent background shows through
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let parser = MarkdownParser()
        let htmlBody = parser.html(from: markdown)
        
        let css = """
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji";
            font-size: 14px;
            line-height: 1.6;
            color: #c9d1d9;
            background-color: #0d1117;
            padding: 24px;
            margin: 0;
            word-wrap: break-word;
        }
        h1, h2, h3, h4, h5, h6 {
            margin-top: 24px;
            margin-bottom: 16px;
            font-weight: 600;
            line-height: 1.25;
            color: #f0f6fc;
        }
        h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid #30363d; }
        h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid #30363d; }
        h3 { font-size: 1.25em; }
        a {
            color: #58a6ff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        code {
            padding: 0.2em 0.4em;
            margin: 0;
            font-size: 85%;
            background-color: rgba(110, 118, 129, 0.4);
            border-radius: 6px;
            font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
        }
        pre {
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: #161b22;
            border-radius: 6px;
            margin-top: 0;
            margin-bottom: 16px;
        }
        pre code {
            padding: 0;
            background-color: transparent;
            border-radius: 0;
            font-size: 100%;
        }
        blockquote {
            padding: 0 1em;
            color: #8b949e;
            border-left: 0.25em solid #30363d;
            margin: 0 0 16px 0;
        }
        ul, ol {
            padding-left: 2em;
            margin-top: 0;
            margin-bottom: 16px;
        }
        li {
            margin-top: 0.25em;
        }
        table {
            border-spacing: 0;
            border-collapse: collapse;
            margin-top: 0;
            margin-bottom: 16px;
            width: 100%;
        }
        table th, table td {
            padding: 6px 13px;
            border: 1px solid #30363d;
        }
        table th {
            font-weight: 600;
            background-color: #161b22;
        }
        table tr:nth-child(2n) {
            background-color: #161b22;
        }
        hr {
            height: 0.25em;
            padding: 0;
            margin: 24px 0;
            background-color: #30363d;
            border: 0;
        }
        img {
            max-width: 100%;
            box-sizing: content-box;
            background-color: transparent;
        }
        """
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                \(css)
            </style>
        </head>
        <body>
            \(htmlBody)
        </body>
        </html>
        """
        
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
