//
//  MenuBarViewModel.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI
import AppKit
import Combine

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var cpuTemp: Int = 0
    @Published var statusImage: NSImage?
    
    private let iconService = IconService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        updateIcon(temp: nil)
        
        // Observe preference changes to update icon
        AppPreferences.shared.$temperatureMode
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateIcon(temp: self.cpuTemp > 0 ? self.cpuTemp : nil)
            }
            .store(in: &cancellables)
    }
    
    func updateIcon(temp: Int?) {
        if let temp = temp {
            self.cpuTemp = temp
        }
        
        // Convert temperature and get symbol on MainActor
        let preferences = AppPreferences.shared
        let displayTemp = temp != nil ? preferences.convertTemperature(temp!) : nil
        let symbol = preferences.temperatureSymbol
        
        // Generate icon with converted values
        self.statusImage = iconService.generateIcon(temp: displayTemp, symbol: symbol)
    }
}
