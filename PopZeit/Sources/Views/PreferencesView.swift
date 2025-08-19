import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @EnvironmentObject var preferencesStore: PreferencesStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            FormattingPreferencesView()
                .tabItem {
                    Label("Formatting", systemImage: "textformat")
                }
                .tag(1)
            
            TimezonesPreferencesView()
                .tabItem {
                    Label("Timezones", systemImage: "globe")
                }
                .tag(2)
            
            AccessibilityPreferencesView()
                .tabItem {
                    Label("Accessibility", systemImage: "accessibility")
                }
                .tag(3)
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralPreferencesView: View {
    @EnvironmentObject var preferencesStore: PreferencesStore
    @State private var launchAtLoginEnabled = false
    
    var body: some View {
        Form {
            Section("Behavior") {
                Toggle("Launch at login", isOn: $launchAtLoginEnabled)
                    .onChange(of: launchAtLoginEnabled) { newValue in
                        toggleLaunchAtLogin(newValue)
                    }
                
                Toggle("Show dock icon", isOn: $preferencesStore.showDockIcon)
                    .onChange(of: preferencesStore.showDockIcon) { newValue in
                        updateDockIconVisibility(newValue)
                    }
                
                // Note: Clipboard monitoring is now the primary method
            }
            
            Section("Popover") {
                HStack {
                    Text("Auto-dismiss after:")
                    Slider(value: $preferencesStore.popoverTimeout, in: 2...10, step: 0.5)
                    Text("\(preferencesStore.popoverTimeout, specifier: "%.1f")s")
                        .frame(width: 40)
                }
                
                Toggle("Show dismiss progress bar", isOn: $preferencesStore.showDismissProgress)
                Toggle("Show relative time", isOn: $preferencesStore.showRelativeTime)
            }
            
            // Note: Feedback section removed - FeedbackProvider was removed
        }
        .padding()
        .onAppear {
            checkLaunchAtLoginStatus()
        }
    }
    
    private func toggleLaunchAtLogin(_ enable: Bool) {
        if #available(macOS 13.0, *) {
            if enable {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }
    
    private func checkLaunchAtLoginStatus() {
        if #available(macOS 13.0, *) {
            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
        }
    }
    
    private func updateDockIconVisibility(_ show: Bool) {
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

struct FormattingPreferencesView: View {
    @EnvironmentObject var preferencesStore: PreferencesStore
    
    var body: some View {
        Form {
            Section("Date Formats") {
                HStack {
                    Text("UTC Format:")
                    TextField("Format", text: $preferencesStore.utcDateFormat)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Local Format:")
                    TextField("Format", text: $preferencesStore.localDateFormat)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Timezone Format:")
                    TextField("Format", text: $preferencesStore.timezoneDateFormat)
                        .textFieldStyle(.roundedBorder)
                }
                
                Toggle("Use locale-aware formatting", 
                       isOn: $preferencesStore.useLocaleAwareFormatting)
            }
            
            Section("Format Examples") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("yyyy-MM-dd HH:mm:ss → 2024-01-15 14:30:45")
                    Text("MMM d, yyyy h:mm a → Jan 15, 2024 2:30 PM")
                    Text("EEEE, MMMM d → Monday, January 15")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            }
            
            Button("Reset to Defaults") {
                preferencesStore.utcDateFormat = "yyyy-MM-dd HH:mm:ss"
                preferencesStore.localDateFormat = "yyyy-MM-dd HH:mm:ss z"
                preferencesStore.timezoneDateFormat = "HH:mm:ss z"
            }
        }
        .padding()
    }
}

struct TimezonesPreferencesView: View {
    @EnvironmentObject var preferencesStore: PreferencesStore
    @State private var searchText = ""
    @State private var selectedTimezone: String?
    
    var availableTimezones: [String] {
        let all = TimeZone.knownTimeZoneIdentifiers
        if searchText.isEmpty {
            return all
        }
        return all.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            Section("Pinned Timezones") {
                List {
                    ForEach(preferencesStore.pinnedTimezones, id: \.self) { timezone in
                        HStack {
                            Text(timezone)
                            Spacer()
                            Button(action: {
                                preferencesStore.removeTimezone(timezone)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 100)
            }
            
            Divider()
            
            Section("Add Timezone") {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search timezones...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
                
                List(availableTimezones, id: \.self, selection: $selectedTimezone) { timezone in
                    HStack {
                        Text(timezone)
                        Spacer()
                        if preferencesStore.pinnedTimezones.contains(timezone) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !preferencesStore.pinnedTimezones.contains(timezone) {
                            preferencesStore.addTimezone(timezone)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct AccessibilityPreferencesView: View {
    @EnvironmentObject var preferencesStore: PreferencesStore
    @State private var accessibilityEnabled = false
    
    var body: some View {
        Form {
            Section("Permissions") {
                HStack {
                    Image(systemName: accessibilityEnabled ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(accessibilityEnabled ? .green : .red)
                    Text("Accessibility Permission")
                    Spacer()
                    Button("Open System Settings") {
                        openAccessibilitySettings()
                    }
                }
                
                Text("PopZeit needs Accessibility permission to read selected text when you double-click.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            Section("Display") {
                HStack {
                    Text("Text size:")
                    Slider(value: $preferencesStore.textSize, in: 11...18, step: 1)
                    Text("\(Int(preferencesStore.textSize))pt")
                        .frame(width: 40)
                }
                
                Toggle("Use high contrast mode", isOn: $preferencesStore.useHighContrast)
            }
        }
        .padding()
        .onAppear {
            checkAccessibilityStatus()
        }
    }
    
    private func checkAccessibilityStatus() {
        accessibilityEnabled = AXIsProcessTrustedWithOptions(nil)
    }
    
    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}