//
//  AppPreferences.swift
//  Summer
//
//  Created by Bruno Castelló on 03/01/26.
//

import SwiftUI

/// Temperature unit options for display
enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    
    var id: String { rawValue }
    
    /// Localized display name for the temperature unit
    var localizedName: LocalizedStringKey {
        switch self {
        case .celsius: return "preferences.temperature.celsius"
        case .fahrenheit: return "preferences.temperature.fahrenheit"
        }
    }
    
    /// Symbol to display after temperature values
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

/// Supported language options
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case portuguese = "pt-BR"
    case spanish = "es"
    
    var id: String { rawValue }
    
    /// Localized display name for the language
    var localizedName: LocalizedStringKey {
        switch self {
        case .english: return "preferences.language.english"
        case .portuguese: return "preferences.language.portuguese"
        case .spanish: return "preferences.language.spanish"
        }
    }
}

/// Application settings stored in UserDefaults
@MainActor
class AppPreferences: ObservableObject {
    /// Selected temperature unit (Celsius or Fahrenheit)
    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(temperatureUnit.rawValue, forKey: "temperatureUnit")
        }
    }
    
    /// Selected application language
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "language")
        }
    }
    
    /// Singleton instance
    static let shared = AppPreferences()
    
    private init() {
        // Load saved temperature unit or default to Celsius
        if let savedUnit = UserDefaults.standard.string(forKey: "temperatureUnit"),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            self.temperatureUnit = unit
        } else {
            self.temperatureUnit = .celsius
        }
        
        // Load saved language or default to English
        if let savedLang = UserDefaults.standard.string(forKey: "language"),
           let lang = AppLanguage(rawValue: savedLang) {
            self.language = lang
        } else {
            self.language = .english
        }
    }
    
    /// Converts Celsius temperature to the selected unit
    /// - Parameter celsius: Temperature in Celsius
    /// - Returns: Temperature in selected unit
    func convertTemperature(_ celsius: Int) -> Int {
        switch temperatureUnit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return Int((Double(celsius) * 9.0 / 5.0) + 32.0)
        }
    }
    
    /// Returns the appropriate temperature symbol based on selected unit
    var temperatureSymbol: String {
        temperatureUnit.symbol
    }
}
