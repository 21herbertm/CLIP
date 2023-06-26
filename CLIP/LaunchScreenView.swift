//
//  LaunchScreenView.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/22/23.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isSpinning = false

    var body: some View {
        ZStack {
            // Setting the background as image
            Image("launch_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150) // Adjusting the size of the logo
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(Animation.linear(duration: 0.2).repeatForever(autoreverses: false))
                    .onAppear {
                        isSpinning = true
                    }
                
            }
        }
    }
}
