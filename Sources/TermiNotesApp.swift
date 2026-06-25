import SwiftUI
import AppKit

@main
struct TermiNotesApp: App {
    @State private var store = AppStore()
    
    init() {
        // Configure as a regular graphical app when executed as a raw binary
        NSApplication.shared.setActivationPolicy(.regular)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .onAppear {
                    // Bring the window to the front
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
    }
}
