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
    static let preferences = AppPreferences.shared
    
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
                    await MainActor.run {
                        AppDelegate.sensorViewModel.updateSensors()
                    }
                } catch {                }
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
    
    /// Opens the Preferences window, creating it if it doesn't exist
    static func openPreferencesWindow() {
        // Check if preferences window already exists
        if let existingWindow = NSApplication.shared.windows.first(where: { 
            $0.identifier?.rawValue == "preferences-window" 
        }) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Create new preferences window
        let preferencesView = PreferencesView()
            .environmentObject(AppDelegate.preferences)
        
        let hostingController = NSHostingController(rootView: preferencesView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.identifier = NSUserInterfaceItemIdentifier("preferences-window")
        window.title = NSLocalizedString("preferences.title", comment: "")
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Preferences")
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
