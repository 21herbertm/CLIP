//
//  ContentView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/16/23.
//
// comment

import SwiftUI
import CoreBluetooth
import AWSMobileClient
import AWSAuthCore
import AWSAuthUI
import Amplify


struct ContentView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var showLaunchScreen = true
    
    @State private var isShowingLogin = false
    @State private var isShowingRegister = false
    @State private var isAuthenticated = true
    @State private var isScanning = false
    @StateObject var awsManager: AWSManager = .shared
    
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    
    let user: AuthUser
    
    var body: some View {
            VStack {
                if isAuthenticated {
                    if isScanning {
                        NavigationLink(destination: ScanDevicesView(isScanning: $isScanning)
                            .environmentObject(bluetoothManager),
                                       isActive: $isScanning) {
                            EmptyView()
                        }
                                       .hidden()
                    } else {
                        NavigationLink(destination: ScanDevicesView(isScanning: $isScanning)
                            .environmentObject(bluetoothManager)) {
                                Text("Scan for devices and Bluetooth pair")
                                    .font(.title)
                                    .padding()
                            }
                    }
                }
                
                if isAuthenticated {
                    TabView {
                        MyClipView()
                            .tabItem {
                                Image(systemName: "bicycle") // Example for a bike-related symbol
                                Text("MyClip")
                            }

                        SupportView()
                            .tabItem {
                                Image(systemName: "message") // You can choose a relevant symbol here
                                Text("Support")
                            }

                        NavigationView {
                            AccountView(user: user)
                                .environmentObject(sessionManager)
                        }
                        .tabItem {
                            Image(systemName: "person.circle") // Symbol for profile
                            Text("Account")
                        }

                        NavigationView {
                            ChartView()
                        }
                        .tabItem {
                            Image(systemName: "chart.bar") // Symbol for charts
                            Text("Charts")
                        }
                        
                        NavigationView {
                            tempview()
                        }
                        .tabItem {
                            Image(systemName: "chart.bar") // Symbol for charts
                            Text("Temperature Chart")
                        }
                        
                        NavigationView {
                            Voltage()
                        }
                        .tabItem {
                            Image(systemName: "chart.bar") // Symbol for charts
                            Text("Voltage Chart")
                        }
                        
                        NavigationView {
                            CombinedCharts()
                        }
                        .tabItem {
                            Image(systemName: "chart.bar") // Symbol for charts
                            Text("Combined Chart")
                        }
                    }
                    .environmentObject(bluetoothManager)
                    .environmentObject(awsManager)
                }
            }
        }
    }
