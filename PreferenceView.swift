import SwiftUI

struct PreferencesView: View {
    @State private var launchAtLogin = false
    @State private var alwaysOnTop = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { value in
                        // In a real app, you would implement this functionality
                        // using SMAppService or a login item helper
                    }
                
                Toggle("Always on top", isOn: $alwaysOnTop)
                    .onChange(of: alwaysOnTop) { value in
                        if let window = NSApp.windows.first {
                            window.level = value ? .floating : .normal
                        }
                    }
                
                Divider()
                
                HStack {
                    Text("Keyboard Shortcut:")
                    Spacer()
                    Text("⌘⌥W")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Button("Close") {
                NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
        .frame(width: 300, height: 200)
        .padding()
        .onAppear {
            // Initialize with current settings
            if let window = NSApp.windows.first {
                alwaysOnTop = window.level == .floating
            }
            
            // In a real app, you would check if the app is configured to launch at login
        }
    }
}

