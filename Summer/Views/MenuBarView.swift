//
//  MenuBarView.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var sensorViewModel: SensorViewModel
    @StateObject var settings = AppSettings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 4) {
                headerView(systemName: "fan.fill", title: "FANS")
                
                VStack(spacing: 0) {
                    ForEach(0..<sensorViewModel.fans.count, id: \.self) { index in
                        FanRow(
                            label: "Fan #\(index + 1)",
                            rpm: sensorViewModel.fans[index],
                            maxRPM: 6000
                        )
                    }
                    
                    if sensorViewModel.fans.isEmpty {
                        FanRow(label: "Fan #1", rpm: 0, maxRPM: 6000)
                        FanRow(label: "Fan #2", rpm: 0, maxRPM: 6000)
                    }
                }
            }
            .padding(.horizontal, 7)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 4) {
                headerView(systemName: "thermometer.medium", title: "SENSORS")
                
                VStack(spacing: 0) {
                    Group {
                        SensorRow(label: "Wi-Fi", temp: sensorViewModel.readings["Wi-Fi"] ?? 0)
                        SensorRow(label: "Battery", temp: sensorViewModel.readings["Battery"] ?? 0)
                        SensorRow(label: "PSU", temp: sensorViewModel.readings["PSU"] ?? 0)
                        SensorRow(label: "Storage", temp: sensorViewModel.readings["Storage"] ?? 0)
                        SensorRow(label: "Enclosure", temp: sensorViewModel.readings["Enclosure"] ?? 0)
                        SensorRow(label: "CPU", temp: sensorViewModel.readings["CPU"] ?? 0)
                        SensorRow(label: "Logic Board", temp: sensorViewModel.readings["Logic Board"] ?? 0)
                        SensorRow(label: "Palm Rest", temp: sensorViewModel.readings["Palm Rest"] ?? 0)
                    }
                }
            }
            .padding(.horizontal, 7)
            .padding(.top, 3)

            Divider().padding(.horizontal, 3)
            
            Button("About Summer") {
                NSApp.orderFrontStandardAboutPanel(nil)
            }
            .buttonStyle(.menuBar)
            
            Button("menubar.settings") {
                openSettingsWindow()
            }
            .buttonStyle(.menuBar)
            
            Divider().padding(.horizontal, 3)
            
            Button("Quit Summer") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.menuBar)
        }
        .padding(5)
        .frame(width: 260)
    }

    private func headerView(systemName: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .medium))
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .kerning(0.5)
        }
        .foregroundColor(.secondary)
        .padding(.bottom, 4)
    }
    
    /// Opens the Settings window, creating it if it doesn't exist
    private func openSettingsWindow() {
        // Check if settings window already exists
        if let existingWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings-window" }) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Create new settings window
        let settingsView = SettingsView()
            .environmentObject(settings)
        
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.identifier = NSUserInterfaceItemIdentifier("settings-window")
        window.title = NSLocalizedString("settings.title", comment: "")
        window.styleMask = [.titled, .closable]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Settings")
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Preview

#Preview {
    let mockViewModel = SensorViewModel()
    
    mockViewModel.fans = [2150, 1980]
    mockViewModel.readings = [
        "Wi-Fi": 38,
        "Battery": 32,
        "PSU": 45,
        "Storage": 35,
        "Enclosure": 30,
        "CPU": 52,
        "Logic Board": 41,
        "Palm Rest": 28
    ]
    
    return MenuBarView()
        .environmentObject(mockViewModel)
        .environmentObject(AppSettings.shared)
        .frame(width: 260)
}
