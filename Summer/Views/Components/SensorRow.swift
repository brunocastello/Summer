//
//  SensorRow.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

/// Displays a single sensor's temperature information with label, value, and visual progress bar
struct SensorRow: View {
    let label: LocalizedStringKey
    let temp: Int
    
    @EnvironmentObject var preferences: AppPreferences
    
    /// Converts and formats the temperature based on user's preferred unit
    private var displayTemp: Int {
        preferences.convertTemperature(temp)
    }
    
    /// Temperature symbol based on current preference
    private var symbol: String {
        preferences.temperatureSymbol
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.9))
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(displayTemp > 0 ? "\(displayTemp)\(symbol)" : "--\(symbol)")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .frame(width: 45, alignment: .trailing)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 55, height: 4)
                    if temp > 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: temperatureColors(temp)),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 55 * min(max(CGFloat(temp)/100.0, 0), 1), height: 4)
                    }
                }
            }
            .frame(width: 108, height: 20, alignment: .trailing)
        }
    }
    
    private func temperatureColors(_ temp: Int) -> [Color] {
        if temp < 45 {
            return [Color.blue, Color(red: 0.3, green: 0.7, blue: 1.0)]
        } else if temp < 60 {
            return [Color.green, Color(red: 0.5, green: 0.9, blue: 0.5)]
        } else {
            return [Color.orange, Color.red]
        }
    }
}
