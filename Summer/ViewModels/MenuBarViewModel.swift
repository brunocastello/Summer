//
//  MenuBarViewModel.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI
import AppKit

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var cpuTemp: Int = 0
    @Published var statusImage: NSImage?
    
    private let iconService = IconService()
    
    init() {
        updateIcon(temp: nil)
    }
    
    func updateIcon(temp: Int?) {
        if let temp = temp {
            self.cpuTemp = temp
        }
        
        self.statusImage = iconService.generateIcon(temp: temp)
    }
}
