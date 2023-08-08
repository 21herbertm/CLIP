//
//  AccountView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//

import Foundation
import SwiftUI
import Amplify

struct AccountView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    let user: AuthUser
    
    var body: some View {
        VStack {
            // Update Firmware button
            Button("Update Firmware") {
                // Call your function to update firmware here
            }
            .foregroundColor(.white)
            .padding()
            .frame(width: 200) // Set a specific width
            .background(Color.black)
            .cornerRadius(10)
            .padding(.top, 10) // Add some top padding if needed
            
            Spacer() // Pushes the sign-out button towards the middle
            
            // Sign Out button
            Button("Sign Out", action: sessionManager.signOut)
                .foregroundColor(.white) // Text color
                .padding()
                .frame(width: 200) // Specific width
                .background(Color(hex: "5abf90")) // Background color to make it stand out
                .cornerRadius(10)
                .padding(.bottom, 20) // Add some bottom padding if needed
        }
        .navigationTitle("Account") // This sets the navigation title
    }
}
