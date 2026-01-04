//
//  SensorService.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import Foundation

final class SensorService: @unchecked Sendable {
    enum ChipType {
        case appleSilicon
        case intel
    }

    private func detectArchitecture(allData: [String: Double]) -> ChipType {
        // Check for Intel keys first
        let hasIntelKeys = SensorsModel.intelCPUKeys.contains { allData[$0] != nil }
        if hasIntelKeys {
            return .intel
        }
        
        // Default to Apple Silicon
        return .appleSilicon
    }
    
    func readSensors() -> SensorData {
        guard let path = Bundle.main.path(forResource: "smc", ofType: nil) else {
            return SensorData()
        }
        
        let allData = getAllSensorData(path: path)
        let (readings, fans) = processSensorData(allData: allData)
        
        return SensorData(readings: readings, fans: fans)
    }
    
    private func getAllSensorData(path: String) -> [String: Double] {
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
                        
                        // Include fan keys even if 0 RPM
                        let isFanKey = SensorsModel.fanKeys.contains(key)
                        
                        if value > 0 || isFanKey {
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
    
    private func processSensorData(allData: [String: Double]) -> ([String: Int], [Int]) {
        var updatedReadings: [String: Int] = [:]
        
        updatedReadings["CPU"] = calculateCPUTemp(allData: allData)
        updatedReadings["GPU"] = calculateGPUTemp(allData: allData)
        updatedReadings["Battery"] = calculateBatteryTemp(allData: allData)
        updatedReadings["Enclosure"] = calculateEnclosureTemp(allData: allData)
        updatedReadings["Wi-Fi"] = calculateWiFiTemp(allData: allData)
        updatedReadings["Storage"] = calculateStorageTemp(allData: allData)
        updatedReadings["Logic Board"] = calculateLogicBoardTemp(allData: allData)
        updatedReadings["Palm Rest"] = calculatePalmRestTemp(allData: allData)
        updatedReadings["PSU"] = calculatePSUTemp(allData: allData)
        
        let fans = detectFans(allData: allData)
        
        return (updatedReadings.compactMapValues { $0 }, fans)
    }
    
    private func detectChipKeys(allData: [String: Double]) -> [String] {
        let m4Check = ["Te05", "Tp0V", "Tg0G"]
        let m3Check = ["Te05", "Tf04", "Tf14"]
        let m2Check = ["Tp1h", "Tg0f"]
        let m1Check = ["Tp09", "Tp0T"]
        
        if m4Check.allSatisfy({ allData[$0] != nil }) {
            return SensorsModel.m4Keys
        } else if m3Check.allSatisfy({ allData[$0] != nil }) {
            return SensorsModel.m3Keys
        } else if m2Check.allSatisfy({ allData[$0] != nil }) {
            return SensorsModel.m2Keys
        } else if m1Check.allSatisfy({ allData[$0] != nil }) {
            return SensorsModel.m1Keys
        }
        
        return SensorsModel.m1Keys
    }
    
    private func calculateCPUTemp(allData: [String: Double]) -> Int? {
        let arch = detectArchitecture(allData: allData)
        
        switch arch {
        case .appleSilicon:
            let chipKeys = detectChipKeys(allData: allData)
            return calculateCPUTempAppleSilicon(allData: allData, chipKeys: chipKeys)
            
        case .intel:
            return calculateCPUTempIntel(allData: allData)
        }
    }
    
    private func calculateCPUTempAppleSilicon(allData: [String: Double], chipKeys: [String]) -> Int? {
        var cpuTemps: [Int] = []
        for key in chipKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 25 && temp < 120 {
                    cpuTemps.append(temp)
                }
            }
        }
        
        guard !cpuTemps.isEmpty else { return nil }
        
        let sum = cpuTemps.reduce(0, +)
        let avgTemp = sum / cpuTemps.count
        return avgTemp
    }

    private func calculateCPUTempIntel(allData: [String: Double]) -> Int? {
        var cpuTemps: [Int] = []
        for key in SensorsModel.intelCPUKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 25 && temp < 120 {
                    cpuTemps.append(temp)
                }
            }
        }
        
        guard !cpuTemps.isEmpty else { return nil }
        let avgTemp = cpuTemps.reduce(0, +) / cpuTemps.count
        return avgTemp
    }
    
    private func calculateGPUTemp(allData: [String: Double]) -> Int? {
        var gpuTemps: [Int] = []
        
        // Try Apple Silicon keys first
        for key in SensorsModel.gpuKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 25 && temp < 120 {
                    gpuTemps.append(temp)
                }
            }
        }
        
        // Try Intel keys if no Apple Silicon keys found
        if gpuTemps.isEmpty {
            for key in SensorsModel.intelGPUKeys {
                if let val = allData[key] {
                    let temp = Int(val.rounded())
                    if temp > 25 && temp < 120 {
                        gpuTemps.append(temp)
                    }
                }
            }
        }
        
        return gpuTemps.max()
    }
    
    private func calculateBatteryTemp(allData: [String: Double]) -> Int? {
        var batteryTemps: [Int] = []
        for key in SensorsModel.batteryKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 60 {
                    batteryTemps.append(temp)
                }
            }
        }
        
        guard !batteryTemps.isEmpty else { return nil }
        let avg = Double(batteryTemps.reduce(0, +)) / Double(batteryTemps.count)
        return Int(avg.rounded())
    }
    
    private func calculateEnclosureTemp(allData: [String: Double]) -> Int? {
        var enclosureTemps: [Int] = []
        for key in SensorsModel.enclosureKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 70 {
                    enclosureTemps.append(temp)
                }
            }
        }
        
        guard !enclosureTemps.isEmpty else { return nil }
        let avg = Double(enclosureTemps.reduce(0, +)) / Double(enclosureTemps.count)
        return Int(avg.rounded())
    }
    
    private func calculateWiFiTemp(allData: [String: Double]) -> Int? {
        for key in SensorsModel.wifiKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 100 {
                    return temp
                }
            }
        }
        return nil
    }
    
    private func calculateStorageTemp(allData: [String: Double]) -> Int? {
        for key in SensorsModel.storageKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 100 {
                    return temp
                }
            }
        }
        return nil
    }
    
    private func calculateLogicBoardTemp(allData: [String: Double]) -> Int? {
        for key in SensorsModel.logicBoardKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 100 {
                    return temp
                }
            }
        }
        return nil
    }
    
    private func calculatePalmRestTemp(allData: [String: Double]) -> Int? {
        var palmRestTemps: [Int] = []
        for key in SensorsModel.palmRestKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 20 && temp < 70 {
                    palmRestTemps.append(temp)
                }
            }
        }
        
        guard !palmRestTemps.isEmpty else { return nil }
        let avg = Double(palmRestTemps.reduce(0, +)) / Double(palmRestTemps.count)
        return Int(avg.rounded())
    }
    
    private func calculatePSUTemp(allData: [String: Double]) -> Int? {
        var psuTemps: [Int] = []
        for key in SensorsModel.psuKeys {
            if let val = allData[key] {
                let temp = Int(val.rounded())
                if temp > 30 && temp < 90 {
                    psuTemps.append(temp)
                }
            }
        }
        
        guard !psuTemps.isEmpty else { return nil }
        let avg = Double(psuTemps.reduce(0, +)) / Double(psuTemps.count)
        return Int(avg.rounded())
    }
    
    /// Detects and returns fan speeds
    /// Returns all fans, including inactive ones (0 RPM)
    private func detectFans(allData: [String: Double]) -> [Int] {
        var detectedFans: [Int] = []
        for key in SensorsModel.fanKeys {
            if let val = allData[key] {
                let rpm = Int(val.rounded())
                detectedFans.append(rpm)
            }
        }
        return detectedFans
    }
    
    private func extractValue(_ input: String) -> Double {
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
