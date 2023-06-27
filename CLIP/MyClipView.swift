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
            // You can present your telemetric data here.
            // Use your bluetoothManager to access the data
        }
        .navigationBarTitle("MyClip", displayMode: .inline)
    }
}
