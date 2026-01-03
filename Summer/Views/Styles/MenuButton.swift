//
//  MenuButton.swift
//  Summer
//
//  Created by Bruno Castelló on 02/01/26.
//

import SwiftUI

// Estilo para botões com borda (ex: Quit em popup separado)
struct MenuButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear)
                    )
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// Estilo para botões da menubar (sem borda, só hover)
struct MenuBarButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered ? Color.primary.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

extension ButtonStyle where Self == MenuButtonStyle {
    static var menu: MenuButtonStyle { MenuButtonStyle() }
}

extension ButtonStyle where Self == MenuBarButtonStyle {
    static var menuBar: MenuBarButtonStyle { MenuBarButtonStyle() }
}
