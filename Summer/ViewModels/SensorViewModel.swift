//
//  SensorViewModel.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import Foundation
import Combine

@MainActor
class SensorViewModel: ObservableObject {
    @Published var readings: [String: Int] = [:]
    @Published var fans: [Int] = []
    
    private let sensorService: SensorService
    private var timer: AnyCancellable?
    private var cachedReadings: [String: Int] = [:]
    
    init() {
        self.sensorService = SensorService()
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
            self.startMonitoring()
        }
    }
    
    func startMonitoring() {
        timer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSensors()
            }
    }
    
    func updateSensors() {
        Task {
            let sensorData = await Task.detached {
                return self.sensorService.readSensors()
            }.value
            
            for (key, value) in sensorData.readings {
                self.cachedReadings[key] = value
            }
            
            self.readings = self.cachedReadings
            self.fans = sensorData.fans
        }
    }
}
