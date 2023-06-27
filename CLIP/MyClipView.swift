//
//  MyClip.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//

import SwiftUI

struct MyClipView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        VStack {
            Text("MyClip Page")
            Text("Telemetric data: \(bluetoothManager.receivedData)")
                .font(.title)
                .padding()
            Button(action: {
                            bluetoothManager.fetchDataFromCharacteristic()
                        }) {
                            Text("Fetch Data")
                        }
        }
        .navigationBarTitle("MyClip", displayMode: .inline)
    }
}
