//
//  PreferencesView.swift
//  Summer
//
//  Created by Bruno Castelló on 03/01/26.
//

import SwiftUI

/// Allows users to configure temperature unit and application language
struct PreferencesView: View {
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        VStack(spacing: 20) {
            // Content Container
            VStack(alignment: .leading, spacing: 12) {
                
                // Temperature Row
                HStack {
                    Text("preferences.temperature.title")
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Picker("", selection: $preferences.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases) { unit in
                            Text(unit.localizedName).tag(unit)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .horizontalRadioGroupLayout()
                }
                
                Divider()
                
                // Language Row
                HStack {
                    Text("preferences.language.title")
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Picker("", selection: $preferences.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.localizedName).tag(lang)
                        }
                    }
                    .frame(width: 150)
                    .pickerStyle(.menu)
                }
                
                Text("preferences.note")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, -4)
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
