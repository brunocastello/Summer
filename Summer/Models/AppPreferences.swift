//
//  AppPreferences.swift
//  Summer
//
//  Created by Bruno Castelló on 03/01/26.
//

import SwiftUI

/// Temperature display mode options
enum TemperatureMode: String, CaseIterable, Identifiable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    case system = "system"
    
    var id: String { rawValue }
    
    /// Localized display name for the temperature mode
    var localizedName: LocalizedStringKey {
        switch self {
        case .celsius: return "preferences.temperature.celsius"
        case .fahrenheit: return "preferences.temperature.fahrenheit"
        case .system: return "preferences.temperature.system"
        }
    }
}

/// Application preferences stored in UserDefaults
@MainActor
class AppPreferences: ObservableObject {
    /// Selected temperature display mode
    @Published var temperatureMode: TemperatureMode {
        didSet {
            UserDefaults.standard.set(temperatureMode.rawValue, forKey: "temperatureMode")
        }
    }
    
    /// Singleton instance
    static let shared = AppPreferences()
    
    private init() {
        // Load saved temperature mode or default to system
        if let savedMode = UserDefaults.standard.string(forKey: "temperatureMode"),
           let mode = TemperatureMode(rawValue: savedMode) {
            self.temperatureMode = mode
        } else {
            self.temperatureMode = .system
        }
    }
    
    /// Determines effective temperature unit based on mode
    private var effectiveUnit: TemperatureUnit {
        switch temperatureMode {
        case .celsius:
            return .celsius
        case .fahrenheit:
            return .fahrenheit
        case .system:
            // Use system locale to determine temperature unit
            return systemPreferredUnit
        }
    }
    
    /// Detects system's preferred temperature unit from locale
    private var systemPreferredUnit: TemperatureUnit {
        let locale = Locale.current
        
        // Check if locale uses Fahrenheit (primarily US territories)
        if locale.measurementSystem == .us {
            return .fahrenheit
        }
        
        // Default to Celsius for rest of world
        return .celsius
    }
    
    /// Converts Celsius temperature to the effective unit
    /// - Parameter celsius: Temperature in Celsius
    /// - Returns: Temperature in effective unit
    func convertTemperature(_ celsius: Int) -> Int {
        switch effectiveUnit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return Int((Double(celsius) * 9.0 / 5.0) + 32.0)
        }
    }
    
    /// Returns the appropriate temperature symbol based on effective unit
    var temperatureSymbol: String {
        switch effectiveUnit {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
}

// MARK: - Internal Types

/// Internal temperature unit (Celsius or Fahrenheit)
private enum TemperatureUnit {
    case celsius
    case fahrenheit
}
