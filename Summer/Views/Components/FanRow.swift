//
//  FanRow.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

struct FanRow: View {
    let label: String
    let rpm: Int
    let maxRPM: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.9))
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(rpm > 0 ? "\(rpm) RPM" : "Inactive")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .frame(width: 75, alignment: .trailing)

                if rpm > 0 {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 55, height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 55 * min(max(CGFloat(rpm)/CGFloat(maxRPM), 0), 1), height: 4)
                    }
                }
            }
            .frame(width: 138, height: 20, alignment: .trailing)
        }
    }
}
