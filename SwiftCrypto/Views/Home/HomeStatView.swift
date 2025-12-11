//
//  HomeStatView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 25/11/2025.
//

import SwiftUI

struct HomeStatView: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var homeVM: HomeViewModel
    @Binding var showPortfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(homeVM.homeStats) { stat in
                StatisticView(stat: stat)
                    .frame(width: screenSize.width / 3)
            }
        }
        .frame(width: screenSize.width, alignment: showPortfolio ? .trailing : .leading)
    }
}

#Preview {
    HomeStatView(showPortfolio: .constant(false))
        .environment(\.screenSize, CGSize(width: 402, height: 0))
        .environmentObject(mockHomeVM)
}
