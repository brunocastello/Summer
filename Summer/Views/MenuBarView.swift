//
//  MenuBarView.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var sensorViewModel: SensorViewModel
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // FANS
            if !sensorViewModel.fans.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    headerView(systemName: "fan.fill", title: "menubar.fans")
                    
                    VStack(spacing: 0) {
                        ForEach(0..<sensorViewModel.fans.count, id: \.self) { index in
                            FanRow(
                                label: "Fan #\(index + 1)",
                                rpm: sensorViewModel.fans[index],
                                maxRPM: 6000
                            )
                        }
                    }
                }
                .padding(.horizontal, 7)
            }

            // SENSORS
            if !sensorViewModel.readings.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    headerView(systemName: "thermometer.medium", title: "menubar.sensors")
                    
                    VStack(spacing: 0) {
                        Group {
                            SensorRow(label: "sensor.wifi", temp: sensorViewModel.readings["Wi-Fi"] ?? 0)
                            SensorRow(label: "sensor.battery", temp: sensorViewModel.readings["Battery"] ?? 0)
                            SensorRow(label: "sensor.psu", temp: sensorViewModel.readings["PSU"] ?? 0)
                            SensorRow(label: "sensor.storage", temp: sensorViewModel.readings["Storage"] ?? 0)
                            SensorRow(label: "sensor.enclosure", temp: sensorViewModel.readings["Enclosure"] ?? 0)
                            SensorRow(label: "sensor.cpu", temp: sensorViewModel.readings["CPU"] ?? 0)
                            SensorRow(label: "sensor.logicboard", temp: sensorViewModel.readings["Logic Board"] ?? 0)
                            SensorRow(label: "sensor.palmrest", temp: sensorViewModel.readings["Palm Rest"] ?? 0)
                        }
                    }
                }
                .padding(.horizontal, 7)
                .padding(.top, sensorViewModel.fans.isEmpty ? 0 : 3)
            }

            Divider().padding(.horizontal, 3)
            
            VStack(spacing: 0) {
                Button("menubar.about") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
                .buttonStyle(.menuBar)
                
                Button("menubar.settings") {
                    AppDelegate.openPreferencesWindow()
                }
                .buttonStyle(.menuBar)
            }
            
            Divider().padding(.horizontal, 3)
            
            Button("menubar.quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.menuBar)
        }
        .padding(5)
        .frame(width: 260)
    }

    private func headerView(systemName: String, title: LocalizedStringKey) -> some View {
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
}

// MARK: - Preview

#Preview {
    let sensorViewModel = SensorViewModel()
    
    sensorViewModel.fans = [2150, 1980]
    sensorViewModel.readings = [
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
        .environmentObject(sensorViewModel)
        .environmentObject(AppPreferences.shared)
        .frame(width: 260)
}
