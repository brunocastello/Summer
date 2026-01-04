//
//  PreferencesView.swift
//  Summer
//
//  Created by Bruno Castelló on 03/01/26.
//

import SwiftUI

/// Allows users to configure temperature display mode and launch at login
struct PreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        VStack(spacing: 20) {
            // Content Container
            VStack(alignment: .leading, spacing: 16) {
                // Temperature Row with Radio Buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("preferences.temperature.title")
                        .font(.system(size: 13, weight: .medium))
                    
                    Picker("", selection: $preferences.temperatureMode) {
                        ForEach(TemperatureMode.allCases) { mode in
                            Text(mode.localizedName).tag(mode)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Launch at Login Checkbox
                Toggle(isOn: $preferences.launchAtLogin) {
                    Text("preferences.launchatlogin")
                        .font(.system(size: 13))
                }
                .toggleStyle(.checkbox)
                
                // Info note
                Text("preferences.note")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(width: 420)
        .navigationTitle("preferences.title")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PreferencesView()
            .environmentObject(AppPreferences.shared)
    }
}
