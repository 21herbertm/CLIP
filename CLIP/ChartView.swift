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

    var body: some View {
        VStack {
            LineView(data: awsManager.rpmChartData, title: "RPM", legend: "RPM over Time").padding()
        }
    }
}
