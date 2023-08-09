//
//  LoginView.swift
//  test
//
//  Created by Shimon Sarkar on 6/27/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Login")
                .font(.largeTitle)
                .padding(.top, 50)
            
            Spacer().frame(height: 50)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(height: 50)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(height: 50)
            
            Button(action: {
                sessionManager.login(username: username, password: password)
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "5abf90"))
                    .cornerRadius(10)
            }
            
            Spacer()
            
            Button(action: sessionManager.showSignUp) {
                Text("Don't have an account? Sign up.")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "5abf90"))
                    .padding()
            }
            
            Button("Sign Out", action: sessionManager.signOut)
                .foregroundColor(.white) // Text color
                .padding()
                .frame(width: 200) // Specific width
                .background(Color(hex: "5abf90")) // Background color to make it stand out
                .cornerRadius(10)
                .padding(.bottom, 20) // Add some bottom padding if needed
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

