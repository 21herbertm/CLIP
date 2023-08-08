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
    @ObservedObject var sessionManager = SessionManager()
    
    init() {
        configureAmplify()
        sessionManager.getCurrentAuthUser()
        UINavigationBar.appearance().tintColor = UIColor(red: 90.0 / 255.0, green: 191.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch sessionManager.authState {
                case .login:
                    LoginView()
                        .environmentObject(sessionManager)
                        .accentColor(Color(hex: "5abf90"))
                    
                case .signUp:
                    SignUpView()
                        .environmentObject(sessionManager)
                        .accentColor(Color(hex: "5abf90"))
                    
                case .confirmCode(let username):
                    ConfirmationView(username: username)
                        .environmentObject(sessionManager)
                        .accentColor(Color(hex: "5abf90"))
                    
                case .session(let user):
                    ContentView(user: user)
                        .environmentObject(bluetoothManager)
                        .environmentObject(sessionManager)
                        .accentColor(Color(hex: "5abf90"))
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
            try Amplify.add(plugin: AWSCognitoAuthPlugin()) // Add this line
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured with storage and auth plugins")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, ((int >> 8) * 17), ((int >> 4 & 0xF) * 17), (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
