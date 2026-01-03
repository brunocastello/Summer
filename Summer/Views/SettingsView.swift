//
//  SettingsView.swift
//  Summer
//
//  Created by Bruno Castelló on 03/01/26.
//

import SwiftUI

/// Allows users to configure temperature unit and application language
struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("settings.title")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            // Settings content
            VStack(alignment: .leading, spacing: 20) {
                // Temperature Unit section
                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.temperature.title")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Picker("", selection: $settings.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases) { unit in
                            Text(unit.localizedName)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Divider()
                
                // Language section
                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.language.title")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Picker("", selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.localizedName)
                                .tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("settings.language.note")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Footer with Close button
            HStack {
                Spacer()
                Button("settings.close") {
                    closeWindow()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(width: 400, height: 280)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    /// Closes the settings window
    private func closeWindow() {
        if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings-window" }) {
            window.close()
        }
    }
}
