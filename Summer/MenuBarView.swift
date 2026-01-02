//
//  MenuBarView.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct MenuBarView: View {
    @EnvironmentObject var sensors: SensorManager
    @EnvironmentObject var menuBar: MenuBarManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Seção de FANS
            VStack(alignment: .leading, spacing: 4) {
                headerView(systemName: "fan.fill", title: "FANS")
                
                VStack(spacing: 0) {
                    ForEach(0..<sensors.fans.count, id: \.self) { index in
                        FanRow(label: "Fan #\(index + 1)", rpm: sensors.fans[index], maxRPM: 6000)
                    }
                    
                    if sensors.fans.isEmpty {
                        FanRow(label: "Fan #1", rpm: 0, maxRPM: 6000)
                        FanRow(label: "Fan #2", rpm: 0, maxRPM: 6000)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider().padding(.horizontal, 12).opacity(0.5)
            
            // Seção de SENSORS
            VStack(alignment: .leading, spacing: 4) {
                headerView(systemName: "thermometer.medium", title: "SENSORS")
                
                VStack(spacing: 0) {
                    Group {
                        SensorRow(label: "Wi-Fi", temp: sensors.readings["Wi-Fi"] ?? 0)
                        SensorRow(label: "Battery", temp: sensors.readings["Battery"] ?? 0)
                        SensorRow(label: "PSU", temp: sensors.readings["PSU"] ?? 0)
                        SensorRow(label: "Storage", temp: sensors.readings["Storage"] ?? 0)
                        SensorRow(label: "Enclosure", temp: sensors.readings["Enclosure"] ?? 0)
                        SensorRow(label: "CPU", temp: sensors.readings["CPU"] ?? 0)
                        SensorRow(label: "Logic Board", temp: sensors.readings["Logic Board"] ?? 0)
                        SensorRow(label: "Palm Rest", temp: sensors.readings["Palm Rest"] ?? 0)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            Divider().padding(.horizontal, 12).opacity(0.5)
            
            // Botão Quit Padronizado (Nativo)
            QuitButton()
                .padding(6)
        }
        .frame(width: 260)
        .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
    }
    
    func headerView(systemName: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .medium))
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .kerning(0.5)
        }
        .foregroundColor(.secondary)
        .padding(.bottom, 4)
    }
}

struct QuitButton: View {
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
            Text("Quit Summer")
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHovered ? Color.primary.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct FanRow: View {
    let label: String
    let rpm: Int
    let maxRPM: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.9))
            
            Spacer() // Empurra tudo o que vem depois para a direita
            
            // Agrupamos o valor e a barra em um bloco de largura fixa total
            HStack(spacing: 8) {
                Text(rpm > 0 ? "\(rpm) RPM" : "Inactive")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .frame(width: 75, alignment: .trailing) // Largura fixa para o texto

                if rpm > 0 {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 55, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                                .frame(width: 55 * min(max(CGFloat(rpm)/6000.0, 0), 1), height: 4)
                    }
                }
            }
            .frame(width: 138, height: 20, alignment: .trailing) // ESTA LINHA TRAVA O CONJUNTO DA DIREITA
        }
    }
}

struct SensorRow: View {
    let label: String
    let temp: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.9))
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(temp > 0 ? "\(temp)°C" : "--°C")
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .frame(width: 45, alignment: .trailing) // Largura fixa para o texto
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 55, height: 4)
                    if temp > 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(gradient: Gradient(colors: temperatureColors(temp)), startPoint: .leading, endPoint: .trailing))
                            .frame(width: 55 * min(max(CGFloat(temp)/100.0, 0), 1), height: 4)
                    }
                }
            }
            .frame(width: 108, height: 20, alignment: .trailing) // ESTA LINHA TRAVA O CONJUNTO DA DIREITA
        }
    }
    
    func temperatureColors(_ temp: Int) -> [Color] {
        if temp < 45 { return [Color.blue, Color(red: 0.3, green: 0.7, blue: 1.0)] }
        else if temp < 60 { return [Color.green, Color(red: 0.5, green: 0.9, blue: 0.5)] }
        else { return [Color.orange, Color.red] }
    }
}
