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

struct ContentView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var isShowingLogin = false
    @State private var isShowingRegister = false
    @State private var isAuthenticated = false
    @State private var isScanning = false
    @StateObject var awsManager: AWSManager = .shared
    
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
                    self.isShowingRegister = false
                    self.isShowingLogin = false
                    self.isAuthenticated = true
                case .unconfirmed:
                    if let deliveryMedium = signUpResult.codeDeliveryDetails?.deliveryMedium,
                       let destination = signUpResult.codeDeliveryDetails?.destination {
                        print("User is not confirmed and needs verification via \(deliveryMedium) sent at \(destination)")
                        self.isShowingRegister = false
                        self.isShowingLogin = false
                        self.isAuthenticated = true
                    } else {
                        print("Code delivery details are missing.")
                    }
                case .unknown:
                    print("Unexpected case")
                }
            } else if let error = error {
                print("Sign up error: \(error.localizedDescription)")
                self.isShowingRegister = false
                self.isShowingLogin = false
                self.isAuthenticated = true
            }
        }
    }
    
    func loginView() -> some View {
        VStack {
            Text("Login Screen")
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
                .padding(.bottom, 20)

            Button(action: {
                AWSMobileClient.default().signIn(username: username, password: password) { (signInResult, error) in
                    if let error = error {
                        print("Sign in error: \(error.localizedDescription)")
                    } else if let signInResult = signInResult {
                        switch(signInResult.signInState) {
                        case .signedIn:
                            print("User is signed in.")
                            isShowingLogin = false
                            isAuthenticated = true
                            isScanning = true
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
                        }else if isShowingRegister {
                        // Add your registration view here
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
                    } else {
                        loginView()
                    }
                    
            if isAuthenticated {
                TabView {
                    MyClipView()
                        .tabItem {
                            Image(systemName: "1.circle")
                            Text("MyClip")
                        }

                    SupportView()
                        .tabItem {
                            Image(systemName: "2.circle")
                            Text("Support")
                        }
                    
                    NavigationView {
                        AccountView()
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationTitle("Account")
                    }
                    .tabItem {
                        Image(systemName: "3.circle")
                        Text("Account")
                    }
                }
                .environmentObject(bluetoothManager)
                .environmentObject(awsManager)
            }
                }
            }
        }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
