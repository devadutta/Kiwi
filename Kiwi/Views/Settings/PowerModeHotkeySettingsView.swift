import SwiftUI
import KeyboardShortcuts

struct PowerModeHotkeySettingsView: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @State private var expandedConfigs: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if powerModeManager.configurations.isEmpty {
                Text("No Power Modes configured. Create Power Modes first to assign hotkeys.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                Text("Enable hotkeys for Power Modes to activate them with keyboard shortcuts.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                ForEach(powerModeManager.configurations) { config in
                    PowerModeHotkeyRow(
                        config: config,
                        isExpanded: expandedConfigs.contains(config.id)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if expandedConfigs.contains(config.id) {
                                expandedConfigs.remove(config.id)
                            } else {
                                expandedConfigs.insert(config.id)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PowerModeHotkeyRow: View {
    let config: PowerModeConfig
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Power Mode info
                HStack(spacing: 8) {
                    Text(config.emoji)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(config.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                        
                        if !config.isEnabled {
                            Text("Disabled")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Hotkey toggle
                Toggle("", isOn: Binding(
                    get: { config.hasHotkey },
                    set: { enabled in
                        powerModeManager.setHotkey(for: config.id, enabled: enabled)
                        if enabled {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onToggleExpanded()
                            }
                        }
                    }
                ))
                .toggleStyle(.switch)
                .disabled(!config.isEnabled)
                .help(config.isEnabled ? "Enable hotkey for this Power Mode" : "Power Mode must be enabled first")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if config.hasHotkey {
                    onToggleExpanded()
                }
            }
            
            // Hotkey recorder (shown when expanded and hotkey is enabled)
            if isExpanded && config.hasHotkey {
                HStack(spacing: 12) {
                    Text("Keyboard Shortcut:")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    KeyboardShortcuts.Recorder(for: .powerMode(config.id))
                        .controlSize(.small)
                    
                    Spacer()
                }
                .padding(.leading, 24)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .opacity(isExpanded ? 1 : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                .opacity(isExpanded ? 1 : 0)
        )
        .padding(.horizontal, isExpanded ? 8 : 0)
    }
}

#Preview {
    PowerModeHotkeySettingsView()
        .frame(width: 500)
        .padding()
}
