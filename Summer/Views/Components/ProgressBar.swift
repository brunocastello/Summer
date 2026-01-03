//
//  ProgressBar.swift
//  Summer
//
//  Created by Bruno Castelló on 03/01/26.
//

import SwiftUI

/// Reusable progress bar component with gradient colors based on value
/// Used for both fan speed and temperature visualization
struct ProgressBar: View {
    /// Current value to display
    let value: Int
    
    /// Maximum possible value (for percentage calculation)
    let maxValue: Int
    
    /// Width of the progress bar in points
    let width: CGFloat
    
    /// Height of the progress bar in points
    let height: CGFloat
    
    /// Type of measurement (affects color gradient)
    let type: BarType
    
    /// Types of progress bars with different color schemes
    enum BarType {
        case fan        // Blue to cyan gradient
        case temperature // Blue → green → orange → red gradient based on temp
    }
    
    /// Calculates the fill percentage (0.0 to 1.0)
    private var percentage: CGFloat {
        guard maxValue > 0 else { return 0 }
        return min(max(CGFloat(value) / CGFloat(maxValue), 0), 1)
    }
    
    /// Returns appropriate gradient colors based on bar type and value
    private var gradientColors: [Color] {
        switch type {
        case .fan:
            // Fan speed: blue (slow) to cyan (fast)
            return [Color.blue, Color.cyan]
            
        case .temperature:
            // Temperature-based gradient
            if value < 45 {
                // Cool: blue to light blue
                return [Color.blue, Color(red: 0.3, green: 0.7, blue: 1.0)]
            } else if value < 60 {
                // Moderate: green
                return [Color.green, Color(red: 0.5, green: 0.9, blue: 0.5)]
            } else {
                // Hot: orange to red
                return [Color.orange, Color.red]
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.primary.opacity(0.08))
                .frame(width: width, height: height)
            
            // Filled progress
            if value > 0 {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: width * percentage, height: height)
            }
        }
    }
}
