//
//  AccountView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var sessionManager: SessionManager
    let user: AuthUser
    
    var body: some View {
        VStack {
            Text("Account Page")
            
            Text("You signed in as \(user.username) using Amplify!!!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Button("Update Firmware") {
                // Call your function to update firmware here
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
            
            Button("Sign Out", action: sessionManager.signOut)
        }
        .navigationBarTitle("Account", displayMode: .inline)
    }
}
