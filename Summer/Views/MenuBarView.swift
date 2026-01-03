//
//  MenuBarView.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var sensorViewModel: SensorViewModel
    
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
}
