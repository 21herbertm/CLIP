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
        VStack {
            Text("CLIP.Bike")
                .font(.title)
                .padding(.top, 20)
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit) // Preserve original aspect ratio
                .frame(width: 200, height: 200) // Adjust frame size as needed
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                .animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: false))
                .onAppear {
                    isSpinning = true
                }
            Text("Bike Easy with this Free App")
                .font(.title)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
