//
//  DeviceDetailView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/20/23.
//

import SwiftUI
import CoreBluetooth

struct DeviceDetailView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @State private var isShowingConnectedAlert = false
    @State private var dismissConnectedAlert = false
    @State private var isShowingFailedToUpdateAlert = false // New state variable

    var device: CBPeripheral

    private var uniqueIdentifier: String {
        "\(device.name ?? "")_\(device.identifier)"
    }

    var body: some View {
        VStack {
            Text(device.name ?? "Unknown Device")
                .font(.title)

            Button(action: {
                if bluetoothManager.connectedDevices.contains(device) {
                    bluetoothManager.disconnectDevice(device)
                } else {
                    bluetoothManager.connectToDevice(device)
                    isShowingConnectedAlert = true
                    dismissConnectedAlert = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismissConnectedAlert = true
                    }
                }
            }) {
                Text(bluetoothManager.connectedDevices.contains(device) ? "Disconnect" : "Connect")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .shadow(radius: 4)
            }

            Button(action: {
                self.bluetoothManager.rebootIntoBootloaderMode()
                self.bluetoothManager.updateFirmware()
            }) {
                Text("Reboot & Update")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .shadow(radius: 4)
            }
        }
        .padding()
        .navigationBarTitle(device.name ?? "Unknown Device")
        .alert(isPresented: $isShowingConnectedAlert) {
            Alert(title: Text("Connected"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $isShowingFailedToUpdateAlert) { // Use the new state variable here
            Alert(title: Text("Failed to Update"), message: Text("Could not update"), dismissButton: .default(Text("OK")))
        }
        .id(uniqueIdentifier) // Set unique identifier for the view
        .onChange(of: dismissConnectedAlert) { dismiss in
            if dismiss {
                isShowingConnectedAlert = false
            }
        }
        .onChange(of: bluetoothManager.dfuUpdateFailed) { failed in // Watch for changes in dfuUpdateFailed flag
            if failed {
                isShowingFailedToUpdateAlert = true // Set the new state variable to show the failed update alert
            }
        }
    }
}
