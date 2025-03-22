import SwiftUI
import HotKey

@main
struct AgeCalculatorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(width: 300, height: 400)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Age Calculator") {
                    appState.showingAbout = true
                }
            }
            
            CommandGroup(replacing: .newItem) { }
            
            CommandMenu("Widget") {
                Button("Show/Hide Widget") {
                    appState.toggleWidget()
                }
                .keyboardShortcut("w", modifiers: [.command, .option])
                
                Divider()
                
                Button("Preferences...") {
                    appState.showingPreferences = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
    
    init() {
        // Configure the app to be a floating panel
        let appearance = NSAppearance(named: .darkAqua)
        NSApp.appearance = appearance
    }
}

// App state to manage the widget visibility and preferences
class AppState: ObservableObject {
    @Published var isWidgetVisible = true
    @Published var showingPreferences = false
    @Published var showingAbout = false
    private var hotKey: HotKey?
    
    init() {
        setupHotkey()
        
        // Register for app activation notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func setupHotkey() {
        // Set up global hotkey (Option+Command+W)
        hotKey = HotKey(key: .w, modifiers: [.command, .option])
        hotKey?.keyDownHandler = { [weak self] in
            self?.toggleWidget()
        }
    }
    
    func toggleWidget() {
        isWidgetVisible.toggle()
        
        if isWidgetVisible {
            showWidget()
        } else {
            hideWidget()
        }
    }
    
    private func showWidget() {
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.level = .floating
            
            // Position the window in the center of the screen
            if let screen = NSScreen.main {
                let screenRect = screen.frame
                let windowRect = window.frame
                let newOrigin = NSPoint(
                    x: screenRect.midX - windowRect.width / 2,
                    y: screenRect.midY - windowRect.height / 2
                )
                window.setFrameOrigin(newOrigin)
            }
        }
    }
    
    private func hideWidget() {
        if let window = NSApp.windows.first {
            window.orderOut(nil)
        }
    }
    
    @objc private func applicationDidBecomeActive() {
        // Make sure the window stays on top when the app becomes active
        if isWidgetVisible, let window = NSApp.windows.first {
            window.level = .floating
        }
    }
}

