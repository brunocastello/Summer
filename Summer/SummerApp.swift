//
//  SummerApp.swift
//  Summer
//
//  Created by Bruno Castelló on 01/01/26.
//

import SwiftUI

/// Main application entry point
/// Manages the menu bar interface and app lifecycle
@main
struct SummerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var menuBarViewModel = AppDelegate.menuBarViewModel

    var body: some Scene {
        // Menu bar extra interface
        MenuBarExtra(
            content: {
                VStack(alignment: .leading, spacing: 5) {
                    MenuBarView()
                        .environmentObject(AppDelegate.sensorViewModel)
                }
                .padding(5)
                .frame(width: 260)
            },
            label: {
                if let image = menuBarViewModel.statusImage {
                    Image(nsImage: image)
                }
            }
        )
        .menuBarExtraStyle(.window)
    }
}
