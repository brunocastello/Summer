//
//  SummerApp.swift
//  Summer
//
//  Created by Bruno Castelló on 01/01/26.
//

import SwiftUI

@main
struct SummerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var menuBarViewModel = AppDelegate.menuBarViewModel

    var body: some Scene {
        MenuBarExtra(
            content: {
                MenuBarView()
                    .environmentObject(AppDelegate.sensorViewModel)
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
