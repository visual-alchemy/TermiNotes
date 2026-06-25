import SwiftUI

struct TabBarView: View {
    @Environment(AppStore.self) private var store
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(store.openTabs) { note in
                    TabItemView(note: note)
                }
            }
        }
        .frame(height: 32)
        .background(Color(nsColor: NSColor(red: 0.06, green: 0.08, blue: 0.10, alpha: 1.0)))
    }
}

struct TabItemView: View {
    @Environment(AppStore.self) private var store
    let note: Note
    @State private var isHovered = false
    
    private var isActive: Bool {
        store.activeTabId == note.id
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(note.title)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(isActive
                    ? Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0))
                    : .gray)
                .lineLimit(1)
            
            // Close button (always laid out to prevent resizing jitter, opacity toggled)
            Button(action: {
                store.closeTab(note.id)
            }) {
                Text("×")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
            .opacity(isHovered || isActive ? 1.0 : 0.0)
            .allowsHitTesting(isHovered || isActive)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            isActive
                ? Color(nsColor: NSColor(red: 0.10, green: 0.13, blue: 0.16, alpha: 1.0))
                : Color.clear
        )
        .overlay(alignment: .bottom) {
            if isActive {
                Rectangle()
                    .fill(Color(nsColor: NSColor(red: 0.24, green: 0.98, blue: 0.34, alpha: 1.0)))
                    .frame(height: 2)
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            store.openTab(note)
        }
    }
}
