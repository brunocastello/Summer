//
//  IconService.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import AppKit

/// Service responsible for generating menubar status icons
class IconService {
    
    /// Generates menubar icon with thermometer symbol and temperature
    /// - Parameters:
    ///   - temp: Temperature already converted to display unit
    ///   - symbol: Temperature symbol (°C or °F)
    /// - Returns: NSImage for menubar display
    func generateIcon(temp: Int?, symbol: String) -> NSImage {
        let tempString = temp != nil ? "\(temp!)\(symbol)" : "--\(symbol)"
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13),
            .foregroundColor: NSColor.labelColor
        ]
        
        let totalWidth: CGFloat = 50  // Increased to accommodate Fahrenheit
        let iconWidth: CGFloat = 16
        let spacing: CGFloat = 0
        
        let textSize = tempString.size(withAttributes: attributes)
        let contentWidth = iconWidth + spacing + textSize.width
        let startX = (totalWidth - contentWidth) / 2
        
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let thermometerImage = NSImage(systemSymbolName: "thermometer.medium", accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
        
        let combinedImage = NSImage(size: NSSize(width: totalWidth, height: 22), flipped: false) { rect in
            guard let thermometerImage = thermometerImage else { return false }
            
            let iconOrigin = NSPoint(x: startX, y: 3)
            thermometerImage.draw(at: iconOrigin, from: .zero, operation: .sourceOver, fraction: 1.0)
            
            let textX = startX + iconWidth + spacing
            let textRect = NSRect(
                x: textX,
                y: (22 - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            tempString.draw(in: textRect, withAttributes: attributes)
            
            return true
        }
        
        combinedImage.isTemplate = true
        
        return combinedImage
    }
}
