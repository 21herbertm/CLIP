//
//  ContentView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/16/23.
//

import SwiftUI
import CoreBluetooth
import AWSMobileClient
import AWSAuthCore
import AWSAuthUI

struct ContentView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var isScanning = false
    @State private var isShowingLogin = false
    @State private var isShowingRegister = false
    
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""

    func register(username: String, password: String, email: String) {
        AWSMobileClient.default().signUp(username: username,
                                          password: password,
                                          userAttributes: ["email" : email]) { (signUpResult, error) in
            if let signUpResult = signUpResult {
                switch signUpResult.signUpConfirmationState {
                case .confirmed:
                    print("User is signed up and confirmed.")
                case .unconfirmed:
                    if let deliveryMedium = signUpResult.codeDeliveryDetails?.deliveryMedium,
                       let destination = signUpResult.codeDeliveryDetails?.destination {
                        print("User is not confirmed and needs verification via \(deliveryMedium) sent at \(destination)")
                    } else {
                        print("Code delivery details are missing.")
                    }
                case .unknown:
                    print("Unexpected case")
                }
            } else if let error = error {
                print("Sign up error: \(error.localizedDescription)")
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Color(UIColor.systemMint)
                    .frame(height: 120)
                    .edgesIgnoringSafeArea(.top)
                
                GeometryReader { geometry in
                    VStack {
                        if bluetoothManager.discoveredDevices.isEmpty {
                            Spacer()
                            
                            Text("No devices found")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding()
                                .shadow(radius: 4)
                            
                            Spacer()
                        } else {
                            List(Array(bluetoothManager.discoveredDevices.enumerated()), id: \.element.identifier) { (index, device) in
                                NavigationLink(destination: DeviceDetailView(device: device)
                                    .environmentObject(bluetoothManager)
                                ) {
                                    Text(device.name ?? "Unknown Device")
                                }
                            }
                        }
                        
                        Button(action: {
                            if isScanning {
                                bluetoothManager.stopScanning()
                            } else {
                                bluetoothManager.startScanning()
                            }
                            isScanning.toggle()
                        }) {
                            Text(isScanning ? "Stop Scanning" : "Scan for Devices")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                                .shadow(radius: 4)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("")
        }
        .onAppear {
            bluetoothManager.startScanning()
            
            // Check if the user is already signed in
            AWSMobileClient.default().initialize { userState, error in
                if let error = error {
                    print("AWSMobileClient initialization error: \(error.localizedDescription)")
                } else {
                    if let userState = userState {
                        print("AWSMobileClient is initialized and userState: \(userState.rawValue)")
                    }
                    
                    if !AWSMobileClient.default().isSignedIn {
                        // Show the login screen
                        isShowingLogin = true
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingLogin) {
            VStack {
                Text("Login Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Text field for username
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                // Text field for password
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)

                Button(action: {
                    // Perform login logic using AWSMobileClient APIs
                    AWSMobileClient.default().signIn(username: username, password: password) { (signInResult, error) in
                        if let error = error {
                            print("Sign in error: \(error.localizedDescription)")
                        } else if let signInResult = signInResult {
                            switch(signInResult.signInState) {
                            case .signedIn:
                                print("User is signed in.")
                                // After successful login, dismiss the login screen
                                isShowingLogin = false
                            default:
                                print("Sign In needs info: \(signInResult.signInState.rawValue)")
                            }
                        }
                    }
                }) {
                    Text("Login")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    isShowingRegister = true
                    isShowingLogin = false
                }) {
                    Text("Register")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .environmentObject(bluetoothManager)
        }
        .sheet(isPresented: $isShowingRegister) {
            VStack {
                Text("Registration Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                       
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)

                Button(action: {
                    register(username: username, password: password, email: email)
                }) {
                    Text("Register")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .environmentObject(bluetoothManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
