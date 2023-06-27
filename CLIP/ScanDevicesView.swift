//
//  ScanDevicesView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//
import SwiftUI
import WebKit

struct ScanDevicesView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Binding var isScanning: Bool
    
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
        }
    }
}
