//
//  MenuBarManager.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI
import AppKit

@MainActor
class MenuBarManager: ObservableObject {
    var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let monitorWrapper = EventMonitorWrapper()
    
    @Published var cpuTemp: Int = 0
    
    func setup(sensors: SensorManager) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = self.statusItem?.button else { return }
        
        button.action = #selector(togglePopover)
        button.target = self
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 250, height: 340)
        popover.behavior = .semitransient
        popover.animates = false
        
        // Remove a seta (anchor) usando a propriedade interna do macOS
        popover.setValue(true, forKeyPath: "shouldHideAnchor")
        
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(sensors)
                .environmentObject(self)
        )
        self.popover = popover
        
        monitorWrapper.monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                if let popover = self?.popover, popover.isShown {
                    popover.performClose(nil)
                }
            }
        }
    }
    
    deinit {
        if let monitor = monitorWrapper.monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func updateIcon(temp: Int?) {
        guard let button = statusItem?.button else { return }
        let tempString = temp != nil ? "\(temp!)°" : "--°"
        if let temp = temp { self.cpuTemp = temp }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13),
            .foregroundColor: NSColor.labelColor
        ]
        
        // 1. FIXAMOS A LARGURA TOTAL
        // Um valor de 48 a 52 costuma ser ideal para acomodar
        // o ícone + 3 dígitos (ex: 100°) sem sobrar muito espaço.
        let totalWidth: CGFloat = 50
        let iconWidth: CGFloat = 18
        let spacing: CGFloat = 1
        
        let textSize = tempString.size(withAttributes: attributes)
        
        // 2. CALCULAMOS O OFFSET PARA CENTRALIZAR O CONJUNTO ÍCONE+TEXTO
        let contentWidth = iconWidth + spacing + textSize.width
        let startX = (totalWidth - contentWidth) / 2
        
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        if let thermometerImage = NSImage(systemSymbolName: "thermometer.medium", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) {
            
            let combinedImage = NSImage(size: NSSize(width: totalWidth, height: 22), flipped: false) { rect in
                // Desenha o ícone centralizado
                let iconOrigin = NSPoint(x: startX, y: 3)
                thermometerImage.draw(at: iconOrigin, from: .zero, operation: .sourceOver, fraction: 1.0)
                
                // Desenha o texto logo após o ícone
                let textX = startX + iconWidth + spacing
                let textRect = NSRect(x: textX, y: (22 - textSize.height) / 2, width: textSize.width, height: textSize.height)
                tempString.draw(in: textRect, withAttributes: attributes)
                return true
            }
            
            combinedImage.isTemplate = true
            button.image = combinedImage
            button.imagePosition = .imageLeading
            button.title = ""
            
            // 3. TRAVAMOS O FRAME DO BOTÃO
            button.frame = NSRect(x: 0, y: 0, width: totalWidth, height: 22)
        }
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            
            var rect = button.bounds
            rect.origin.y -= 6
            
            popover.show(relativeTo: rect, of: button, preferredEdge: .minY)
        }
    }
    
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}

class EventMonitorWrapper: @unchecked Sendable {
    var monitor: Any?
}
