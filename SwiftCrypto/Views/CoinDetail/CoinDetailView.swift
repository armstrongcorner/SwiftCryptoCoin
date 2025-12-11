//
//  CoinDetailView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 30/11/2025.
//

import SwiftUI

struct CoinDetailView: View {
    @StateObject var vm: CoinDetailViewModel
    @State private var readMore: Bool = false
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    private let gridSpacing: CGFloat = 30
    
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
            
            ScrollView {
                ZStack {
                    Color.theme.background
                    
                    VStack(alignment: .leading) {
                        ChartView(coin: vm.coin)
                        
                        overviewSection
                            .padding(.top, 10)
                        
                        additionalSection
                        
                        websiteSection
                    }
                    .padding()
                }
            }
            .navigationTitle(vm.coin.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Text(vm.coin.symbol.uppercased())
                            .font(.headline)
                            .foregroundStyle(Color.theme.secondaryText)
                        CoinImageView(coin: vm.coin)
                            .frame(width: 25, height: 25)
                    }
                }
            }
        }
    }
}

// MARK: - UI Extension
extension CoinDetailView {
    @ViewBuilder
    private var overviewSection: some View {
        Text("Overview")
            .font(.title)
            .bold()
            .foregroundStyle(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Divider()
        
        overviewDescription
        
        overviewGrid
    }
    
    @ViewBuilder
    private var overviewDescription: some View {
        if let description = vm.description, !description.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text(vm.description ?? "")
                    .font(.callout)
                    .foregroundStyle(Color.theme.secondaryText)
                    .lineLimit(readMore ? nil : 3)
                
                Button {
                    withAnimation(.easeInOut) {
                        readMore.toggle()
                    }
                } label: {
                    Text(!readMore ? "Read more" : "Less")
                        .font(.callout)
                }
            }
        }
    }
    
    private var overviewGrid: some View {
        LazyVGrid(
            columns: gridColumns,
            alignment: .leading,
            spacing: gridSpacing,
            pinnedViews: []) {
                ForEach(vm.overviewStatistics ) { overviewStat in
                    StatisticView(stat: overviewStat)
                }
            }
    }
    
    @ViewBuilder
    private var additionalSection: some View {
        Text("Additional Details")
            .font(.title)
            .bold()
            .foregroundStyle(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Divider()
        
        LazyVGrid(
            columns: gridColumns,
            alignment: .leading,
            spacing: gridSpacing,
            pinnedViews: []) {
                ForEach(vm.additionalStatistics) { additionalStat in
                    StatisticView(stat: additionalStat)
                }
            }
    }
    
    @ViewBuilder
    private var websiteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let urlString = vm.homePageUrlString, let url = URL(string: urlString) {
                Link("Website", destination: url)
            }
            if let urlString = vm.subredditUrlString, let url = URL(string: urlString) {
                Link("Reddit", destination: url)
            }
        }
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        CoinDetailView(coin: mockCoin1)
    }
}
