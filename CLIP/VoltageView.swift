//
//  VoltageView.swift
//  Pods
//
//  Created by Melanie Herbert on 8/8/23.
//

import SwiftUI
import SwiftUICharts

struct Voltage: View {
    @ObservedObject var awsManager = AWSManager.shared

    var body: some View {
        VStack {
            LineView(data: awsManager.voltageChartData, title: "temp", legend: "temp over Time").padding()
        }
    }
}
