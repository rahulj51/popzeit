import SwiftUI

struct PopoverView: View {
    let model: DisplayModel
    let onClose: () -> Void
    
    @State private var copiedField: String? = nil
    @State private var showProgressBar = true
    @EnvironmentObject var preferencesStore: PreferencesStore
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with timestamp info
            HStack {
                if let format = model.timestampFormat {
                    Label(format.description, systemImage: "number.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if model.isAmbiguous {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .help("Timestamp may be ambiguous (outside typical range)")
                }
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // Time displays
            VStack(spacing: 8) {
                // UTC Time
                TimeRow(
                    label: "UTC",
                    value: model.utcString,
                    icon: "globe",
                    isCopied: copiedField == "utc"
                ) {
                    copyToClipboard(model.utcString, field: "utc")
                }
                
                // Local Time
                TimeRow(
                    label: "Local",
                    value: model.localString,
                    icon: "location",
                    isCopied: copiedField == "local"
                ) {
                    copyToClipboard(model.localString, field: "local")
                }
                
                // Relative Time
                if preferencesStore.showRelativeTime {
                    TimeRow(
                        label: "Relative",
                        value: model.relativeString,
                        icon: "clock.arrow.circlepath",
                        isCopied: copiedField == "relative"
                    ) {
                        copyToClipboard(model.relativeString, field: "relative")
                    }
                }
                
                // Additional timezones
                ForEach(model.additionalTimezones) { tz in
                    TimeRow(
                        label: tz.label,
                        value: tz.value,
                        icon: "clock",
                        isCopied: copiedField == tz.id
                    ) {
                        copyToClipboard(tz.value, field: tz.id)
                    }
                }
            }
            .padding(.horizontal)
            
            // Progress bar for auto-dismiss
            if showProgressBar && preferencesStore.showDismissProgress {
                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
                    .padding(.horizontal)
                    .onAppear {
                        withAnimation(.linear(duration: preferencesStore.popoverTimeout)) {
                            showProgressBar = false
                        }
                    }
            }
            
            Spacer()
        }
        .frame(width: 360, height: model.additionalTimezones.isEmpty ? 200 : 240)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func copyToClipboard(_ text: String, field: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            copiedField = field
        }
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                copiedField = nil
            }
        }
    }
}

struct TimeRow: View {
    let label: String
    let value: String
    let icon: String
    let isCopied: Bool
    let onCopy: () -> Void
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .frame(width: 80, alignment: .leading)
                .font(.system(.body, design: .default))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onCopy) {
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundColor(isCopied ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .help(isCopied ? "Copied!" : "Copy to clipboard")
        }
        .padding(.vertical, 2)
    }
}