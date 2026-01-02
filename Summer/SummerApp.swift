//
//  SummerApp.swift
//  Summer
//
//  Created by Bruno Castelló on 01/01/26.
//

import SwiftUI
import AppKit

@main
struct SummerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    // 1. Torne estas instâncias estáticas para persistência absoluta
    static let sensors = SensorManager()
    static let menuBar = MenuBarManager()
    private var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // 2. Use as instâncias estáticas
        AppDelegate.menuBar.setup(sensors: AppDelegate.sensors)
        
        // Garante que o --°C apareça imediatamente
        AppDelegate.menuBar.updateIcon(temp: nil)
        
        self.startMonitoring()
        
        if HelperInstaller.shouldRedeploy() {
            // Chama o alerta de instalação/atualização
            self.showInstallAlert()
        }
    }
    
    private func showInstallAlert() {
        let alert = NSAlert()
        alert.messageText = "Install Privileged Helper"
        alert.informativeText = "Summer needs to install a helper to authorize the SMC binary to read hardware sensors."
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Cancel")
        
        // Garante que o alerta apareça na frente de tudo
        NSApp.activate(ignoringOtherApps: true)
        
        // Voltamos para o runModal() que você estava usando, mas com um truque:
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // 1. Criamos uma Task descolada da Main Thread para rodar o script
            Task.detached(priority: .userInitiated) {
                do {
                    // Isso agora roda em background, eliminando o purple warning
                    try HelperInstaller.install()
                    
                    print("✅ Helper installed successfully")
                    
                    // 2. Após instalar, voltamos à Main Thread apenas para atualizar os dados
                    await MainActor.run {
                        AppDelegate.sensors.updateHardwareData()
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
                let cpuTemp = AppDelegate.sensors.readings["CPU"]
                AppDelegate.menuBar.updateIcon(temp: cpuTemp)
            }
        }
    }
}
