//
//  CLIPApp.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/16/23.
//

import SwiftUI
import iOSDFULibrary

@main
struct CLIPApp: App {
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if bluetoothManager.showLaunchScreen {
                    LaunchScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                bluetoothManager.showLaunchScreen = false
                            }
                        }
                } else {
                    ContentView()
                        .environmentObject(bluetoothManager)
                }
            }
        }
    }
}

