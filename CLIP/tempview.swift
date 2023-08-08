//
//  tempview.swift
//  CLIP
//
//  Created by Melanie Herbert on 8/8/23.
//

import SwiftUI
import SwiftUICharts

struct tempview: View {
    @ObservedObject var awsManager = AWSManager.shared

    var body: some View {
        VStack {
            LineView(data: awsManager.temperatureChartData, title: "temp", legend: "temp over Time").padding()
        }
    }
}
