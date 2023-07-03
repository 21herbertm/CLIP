//
//  CLIPApp.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/16/23.
//
import SwiftUI
import iOSDFULibrary
import Amplify
import AmplifyPlugins

@main
struct CLIPApp: App {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    init() {
        configureAmplify()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if bluetoothManager.showLaunchScreen {
                    LaunchScreenView()
                } else {
                    NavigationView {
                        ContentView()
                            .environmentObject(bluetoothManager)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    bluetoothManager.showLaunchScreen = false
                }
            }
        }
    }
    
    // Add the AWS Cognito Plugin
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print("Could not initialize Amplify", error)
        }
    }
}
