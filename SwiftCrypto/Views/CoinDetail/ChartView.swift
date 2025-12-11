//
//  ChartView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 03/12/2025.
//

import SwiftUI

struct ChartView: View {
    private let chartData: [Double]
    
    private let lineColor: Color
    private let minY: Double
    private let maxY: Double
    private let startDate: Date
    private let endDate: Date
    
    @State private var progressShown: CGFloat = 0
    
    init(coin: CoinModel) {
        chartData = coin.sparklineIn7D?.price ?? []
        lineColor = chartData.last ?? 0 > chartData.first ?? 0 ? Color.theme.green : Color.theme.red
        minY = chartData.min() ?? 0.0
        maxY = chartData.max() ?? 0.0
        endDate = Date(coinGeckoDateString: coin.lastUpdated ?? "")
        startDate = endDate.addingTimeInterval(-7*24*60*60)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            chartView
                .frame(height: 200)
                .background(
                    backgroundView
                )
                .overlay(alignment: .leading) {
                    chartYAxis
                }
            
            chartDateLabel
        }
        .font(.caption)
        .foregroundStyle(Color.theme.secondaryText)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 2)) {
                    progressShown = 1
                }
            }
        }
    }
}

// MARK: - UI extension
extension ChartView {
    private var chartView: some View {
        GeometryReader { proxy in
            Path { path in
                for index in chartData.indices {
                    let xPosition = proxy.size.width / CGFloat(chartData.count) * CGFloat(index + 1)
                    let yAxis = maxY - minY
                    let yPosition = (1 - ((chartData[index] - minY) / yAxis)) * proxy.size.height
                    let nextPoint = CGPoint(x: xPosition, y: yPosition)
                    
                    if index == 0 {
                        path.move(to: nextPoint)
                    } else {
                        path.addLine(to: nextPoint)
                    }
                }
            }
            .trim(from: 0, to: progressShown)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .shadow(color: lineColor, radius: 10, x: 0, y: 10)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x: 0, y: 10)
            .shadow(color: lineColor.opacity(0.3), radius: 10, x: 0, y: 20)
            .shadow(color: lineColor.opacity(0.1), radius: 10, x: 0, y: 30)
        }
    }
    
    private var backgroundView: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var chartYAxis: some View {
        VStack {
            Text(maxY.formattedWithAbbreviations())
            Spacer()
            Text("\(((minY + maxY) / 2.0).formattedWithAbbreviations())")
            Spacer()
            Text(minY.formattedWithAbbreviations())
        }
    }
    
    private var chartDateLabel: some View {
        HStack {
            Text(startDate.asShortDateString())
            
            Spacer()
            
            Text(endDate.asShortDateString())
        }
    }
}

// MARK: - Previews
#Preview("green") {
    ChartView(coin: mockCoin1)
}

#Preview("red") {
    ChartView(coin: mockCoin2)
}
