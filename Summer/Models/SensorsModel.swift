//
//  SensorsModel.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import Foundation

struct SensorsModel {
    static let intelCPUKeys = [
        "TC0D", "TC0E", "TC0F", "TC0P",  // CPU Die
        "TC1D", "TC1E", "TC1F", "TC1P",  // CPU cores
        "TC2D", "TC2E", "TC2F", "TC2P",
        "TC3D", "TC3E", "TC3F", "TC3P",
        "TCAD", "TCXC"                   // CPU average
    ]

    static let intelGPUKeys = [
        "TG0D", "TG0P", "TG1D", "TGDD"   // GPU Die
    ]
    
    static let m1Keys = [
        "Tp09", "Tp0T",
        "Tp01", "Tp05", "Tp0D", "Tp0H", "Tp0L", "Tp0P", "Tp0X", "Tp0b",
        "Tg05", "Tg0D", "Tg0L", "Tg0T"
    ]
    
    static let m2Keys = [
        "Tp1h", "Tp1t", "Tp1p", "Tp1l",
        "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0X", "Tp0b", "Tp0f", "Tp0j",
        "Tg0f", "Tg0j"
    ]
    
    static let m3Keys = [
        "Te05", "Te0L", "Te0P", "Te0S",
        "Tf04", "Tf09", "Tf0A", "Tf0B", "Tf0D", "Tf0E",
        "Tf44", "Tf49", "Tf4A", "Tf4B", "Tf4D", "Tf4E",
        "Tf14", "Tf18", "Tf19", "Tf1A", "Tf24", "Tf28", "Tf29", "Tf2A"
    ]
    
    static let m4Keys = [
        "Te05", "Te0S", "Te09", "Te0H",
        "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0V", "Tp0Y", "Tp0b", "Tp0e",
        "Tg0G", "Tg0H", "Tg1U", "Tg1k", "Tg0K", "Tg0L", "Tg0d", "Tg0e", "Tg0j", "Tg0k"
    ]
    
    static let gpuKeys = [
        "Tg0D", "Tg05", "Tg0L", "Tg0T", "Tg0f", "Tg0j",
        "Tg0G", "Tg0H", "Tg1U", "Tg1k", "Tg0K", "Tg0d", "Tg0e", "Tg0k"
    ]
    
    static let batteryKeys = ["TB0T", "TB1T", "TB2T", "TB3T"]
    static let enclosureKeys = ["TaRF", "TaLP", "TA0P", "TH0x", "TH0a", "TCHP"]
    static let wifiKeys = ["TW0P"]
    static let storageKeys = ["NAn0", "TH0a", "TH0x", "TH0A"]
    
    // Logic Board keys - multiple options for compatibility
    static let logicBoardKeys = [
        "TCHP",  // Platform Controller Hub (newer Macs)
        "TPCD",  // Platform Controller Hub Die (common Intel)
        "TP0P",  // Platform Controller (some models)
        "TM0P"   // Memory Proximity (fallback)
    ]
    
    static let palmRestKeys = ["Ts0P", "Ts1P"]
    static let psuKeys = ["Tp0C", "Tp1C", "TPCD"]
    static let fanKeys = ["F0Ac", "F1Ac", "F2Ac", "F3Ac"]
}

struct SensorData {
    var readings: [String: Int] = [:]
    var fans: [Int] = []
}
