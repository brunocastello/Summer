//
//  SensorManager.swift
//  Summer
//
//  Created by Bruno Castelló on 01/01/26.
//

import Foundation
import Combine

@MainActor
class SensorManager: ObservableObject {
    @Published var readings: [String: Int] = [:]
    @Published var fans: [Int] = []
    @Published var maxFanSpeed: Int = 6000
    private var timer: AnyCancellable?
    private var cachedReadings: [String: Int] = [:]
    
    private let m1Keys = [
        "Tp09", "Tp0T",
        "Tp01", "Tp05", "Tp0D", "Tp0H", "Tp0L", "Tp0P", "Tp0X", "Tp0b",
        "Tg05", "Tg0D", "Tg0L", "Tg0T"
    ]
    private let m2Keys = [
        "Tp1h", "Tp1t", "Tp1p", "Tp1l",
        "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0X", "Tp0b", "Tp0f", "Tp0j",
        "Tg0f", "Tg0j"
    ]
    private let m3Keys = [
        "Te05", "Te0L", "Te0P", "Te0S",
        "Tf04", "Tf09", "Tf0A", "Tf0B", "Tf0D", "Tf0E",
        "Tf44", "Tf49", "Tf4A", "Tf4B", "Tf4D", "Tf4E",
        "Tf14", "Tf18", "Tf19", "Tf1A", "Tf24", "Tf28", "Tf29", "Tf2A"
    ]
    private let m4Keys = [
        "Te05", "Te0S", "Te09", "Te0H",
        "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0V", "Tp0Y", "Tp0b", "Tp0e",
        "Tg0G", "Tg0H", "Tg1U", "Tg1k", "Tg0K", "Tg0L", "Tg0d", "Tg0e", "Tg0j", "Tg0k"
    ]

    init() {
        timer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateHardwareData()
                }
            }
    }
    
    nonisolated private func detectChipKeys(allData: [String: Double]) -> [String] {
        let m4Check = ["Te05", "Tp0V", "Tg0G"]
        let m3Check = ["Te05", "Tf04", "Tf14"]
        let m2Check = ["Tp1h", "Tg0f"]
        let m1Check = ["Tp09", "Tp0T"]
        
        if m4Check.allSatisfy({ allData[$0] != nil }) {
            return m4Keys
        } else if m3Check.allSatisfy({ allData[$0] != nil }) {
            return m3Keys
        } else if m2Check.allSatisfy({ allData[$0] != nil }) {
            return m2Keys
        } else if m1Check.allSatisfy({ allData[$0] != nil }) {
            return m1Keys
        }
        
        return m1Keys
    }

    nonisolated private func getAllSensorData(path: String) -> [String: Double] {
        var results: [String: Double] = [:]
        
        let task = Process()
        let pipe = Pipe()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = ["-l"]
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")
                
                for line in lines {
                    if line.isEmpty { continue }
                    
                    let parts = line.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
                    
                    if parts.count >= 2 {
                        let key = parts[0]
                        let value = extractValue(line)
                        if value > 0 {
                            results[key] = value
                        }
                    }
                }
            }
        } catch {
            return results
        }
        
        return results
    }

    func updateHardwareData() {
        guard let path = Bundle.main.path(forResource: "smc", ofType: nil) else { return }

        Task.detached {
            let updatedReadings = self.readAllSensors(path: path)
            
            await MainActor.run {
                for (key, value) in updatedReadings.0 {
                    self.cachedReadings[key] = value
                }
                
                self.readings = self.cachedReadings
                self.fans = updatedReadings.1
            }
        }
    }
    
    nonisolated private func readAllSensors(path: String) -> ([String: Int], [Int]) {
        var updatedReadings: [String: Int] = [:]
        
        let allData = getAllSensorData(path: path)
        let chipKeys = detectChipKeys(allData: allData)

        var cpuTemps: [Int] = []
        for key in chipKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 25 && temp < 120 {
                    cpuTemps.append(temp)
                }
            }
        }
        if !cpuTemps.isEmpty {
            let avgCPU = Double(cpuTemps.reduce(0, +)) / Double(cpuTemps.count)
            updatedReadings["CPU"] = Int(avgCPU.rounded())
        }

        let gpuKeys = ["Tg0D", "Tg05", "Tg0L", "Tg0T", "Tg0f", "Tg0j", "Tg0G", "Tg0H", "Tg1U", "Tg1k", "Tg0K", "Tg0d", "Tg0e", "Tg0k"]
        var gpuTemps: [Int] = []
        for key in gpuKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 25 && temp < 120 {
                    gpuTemps.append(temp)
                }
            }
        }
        if !gpuTemps.isEmpty {
            updatedReadings["GPU"] = gpuTemps.max()!
        }

        var batteryTemps: [Int] = []
        for i in 0...3 {
            if let val = allData["TB\(i)T"] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 60 {
                    batteryTemps.append(temp)
                }
            }
        }
        if !batteryTemps.isEmpty {
            let avg = Double(batteryTemps.reduce(0, +)) / Double(batteryTemps.count)
            updatedReadings["Battery"] = Int(avg.rounded())
        }

        let enclosureKeys = ["TaRF", "TaLP", "TA0P", "TH0x", "TH0a", "TCHP"]
        var enclosureTemps: [Int] = []
        for key in enclosureKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 70 {
                    enclosureTemps.append(Int(val))
                }
            }
        }
        if !enclosureTemps.isEmpty {
            let avg = Double(enclosureTemps.reduce(0, +)) / Double(enclosureTemps.count)
            updatedReadings["Enclosure"] = Int(avg.rounded())
        }

        let wifiKeys = ["TW0P"]
        for key in wifiKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 100 {
                    updatedReadings["Wi-Fi"] = temp
                    break
                }
            }
        }

        let storageKeys = ["NAn0", "TH0a", "TH0x", "TH0A"]
        for key in storageKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 100 {
                    updatedReadings["Storage"] = temp
                    break
                }
            }
        }

        let logicBoardKeys = ["TCHP"]
        for key in logicBoardKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 100 {
                    updatedReadings["Logic Board"] = temp
                    break
                }
            }
        }

        var palmRestTemps: [Int] = []
        let palmRestKeys = ["Ts0P", "Ts1P"]
        for key in palmRestKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 70 {
                    palmRestTemps.append(temp)
                }
            }
        }
        if !palmRestTemps.isEmpty {
            let avg = Double(palmRestTemps.reduce(0, +)) / Double(palmRestTemps.count)
            updatedReadings["Palm Rest"] = Int(avg.rounded())
        }

        var psuTemps: [Int] = []
        let psuKeys = ["Tp0C", "Tp1C", "TPCD"]
        for key in psuKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 30 && temp < 90 {
                    psuTemps.append(temp)
                }
            }
        }
        if !psuTemps.isEmpty {
            let avg = Double(psuTemps.reduce(0, +)) / Double(psuTemps.count)
            updatedReadings["PSU"] = Int(avg.rounded())
        }

        var detectedFans: [Int] = []
        for i in 0..<4 {
            if let val = allData["F\(i)Ac"] {
                let rpm = Int(val.rounded())
                if rpm > 0 {
                    detectedFans.append(rpm)
                }
            }
        }

        return (updatedReadings, detectedFans)
    }

    nonisolated func extractValue(_ input: String) -> Double {
        let pattern = "[0-9.]+"
        if let bracketRange = input.range(of: "]") {
            let searchRange = bracketRange.upperBound..<input.endIndex
            if let numberRange = input.range(of: pattern, options: .regularExpression, range: searchRange) {
                return Double(input[numberRange]) ?? 0
            }
        }
        return 0
    }
}
