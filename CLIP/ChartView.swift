//
//  ChartView.swift
//  CLIP
//
//  Created by Melanie Herbert on 7/24/23.
//

import SwiftUI
import SwiftUICharts

struct ChartView: View {
    @ObservedObject var awsManager = AWSManager.shared

    // Define the colors for each line
    let rpmColor = GradientColor(start: .red, end: .orange)
    let voltageColor = GradientColor(start: .green, end: .blue)
    let temperatureColor = GradientColor(start: .purple, end: .pink)

    var body: some View {
        ScrollView {
            VStack {
                LineView(data: awsManager.rpmChartData, title: "RPM", legend: "RPM over Time").padding()

                LineView(data: awsManager.voltageChartData, title: "Voltage", legend: "Voltage over Time").padding()

                LineView(data: awsManager.temperatureChartData, title: "Temperature", legend: "Temperature over Time").padding()

                MultiLineChartView(data: [(awsManager.rpmChartData, rpmColor), (awsManager.voltageChartData, voltageColor), (awsManager.temperatureChartData, temperatureColor)], title: "Combined", legend: "RPM, Voltage, and Temperature over Time").padding()
            }
        }
    }
}
