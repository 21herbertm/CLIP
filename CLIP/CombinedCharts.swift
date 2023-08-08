//
//  SwiftUIView.swift
//  CLIP
//
//  Created by Melanie Herbert on 8/8/23.
//

import SwiftUI

struct CombinedCharts: View {
    @ObservedObject var awsManager = AWSManager.shared

    var body: some View {
        VStack {
            MultiLineChartView(
                data: [
                    (awsManager.rpmChartData, Color.red),
                    (awsManager.temperatureChartData, Color.green),
                    (awsManager.voltageChartData, Color.blue)
                ]
            )
            .padding()
        }
    }
}

struct MultiLineChartView: View {
    var data: [(points: [Double], color: Color)]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(data.indices) { index in
                let points = data[index].points
                if !points.isEmpty {
                    Path { path in
                        let scaleFactor = geometry.size.height / CGFloat(points.max() ?? 1)
                        let xStep = geometry.size.width / CGFloat(points.count - 1)
                        
                        path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(points[0]) * scaleFactor))
                        
                        for i in 1..<points.count {
                            let point = CGPoint(x: CGFloat(i) * xStep,
                                                y: geometry.size.height - CGFloat(points[i]) * scaleFactor)
                            path.addLine(to: point)
                        }
                    }
                    .stroke(data[index].color, lineWidth: 2)
                }
            }
        }
    }
}
