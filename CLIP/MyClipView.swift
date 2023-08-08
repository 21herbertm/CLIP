//
//  MyClip.swift
//  CLIP
//
//  Created by Melanie Herbert on 6/27/23.
//

import SwiftUI

struct MyClipView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @ObservedObject var awsManager = AWSManager.shared // Make sure to observe AWSManager
    
    let mpg: Double = 25.0 // Miles per Gallon - specific to the vehicle
        let costPerGallon: Double = 3.00 // Cost per Gallon in your area

        var fuelSavings: Double {
            return awsManager.totalMiles / mpg * costPerGallon
        }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 2) // Adjust the space to place the box right below the title

                // Box for telemetric data
                VStack {
                    Text("Telemetric data:")
                    Text("\(bluetoothManager.receivedData)")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                // Box for total miles
                VStack {
                    Text("Total Miles:")
                    Text("\(awsManager.totalMiles, specifier: "%.2f") Miles")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                VStack {
                            Text("Fuel Savings:")
                            Text("$\(fuelSavings, specifier: "%.2f")")
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)

                Spacer() // Fill available space to push the button down

                // Refresh Data button
                Button(action: {
                    bluetoothManager.fetchDataFromCharacteristic()
                }) {
                    Text("Refresh Data")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer(minLength: 2) // Adjust the space to place the button lower on the page
            }
            .navigationTitle("MyClip")
        }
    }
}
