//
//  AppDelegate.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI
import AppKit

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    static let sensorViewModel = SensorViewModel()
    static let menuBarViewModel = MenuBarViewModel()
    
    private var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        AppDelegate.menuBarViewModel.updateIcon(temp: nil)
        
        startMonitoring()
        
        if HelperInstaller.shouldRedeploy() {
            showInstallAlert()
        }
    }
    
    private func showInstallAlert() {
        let alert = NSAlert()
        alert.messageText = "Install Privileged Helper"
        alert.informativeText = "Summer needs to install a helper to authorize the SMC binary to read hardware sensors."
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Cancel")
        
        NSApp.activate(ignoringOtherApps: true)
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            Task.detached(priority: .userInitiated) {
                do {
                    try HelperInstaller.install()
                    print("✅ Helper installed successfully")
                    
                    await MainActor.run {
                        AppDelegate.sensorViewModel.updateSensors()
                    }
                } catch {
                    print("❌ Error during installation: \(error)")
                }
            }
        }
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                let cpuTemp = AppDelegate.sensorViewModel.readings["CPU"]
                AppDelegate.menuBarViewModel.updateIcon(temp: cpuTemp)
            }
        }
    }
}
