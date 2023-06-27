//
//  AccountView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        VStack {
            Text("Account Page")
            Button("Update Firmware") {
                // Call your function to update firmware here
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationBarTitle("Account", displayMode: .inline)
    }
}
