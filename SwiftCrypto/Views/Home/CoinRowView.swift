//
//  CoinRowView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 22/11/2025.
//

import SwiftUI

struct CoinRowView: View {
    @Environment(\.screenSize) private var screenSize
    
    let coin: CoinModel
    let showHoldingsColumn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Rank
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .frame(minWidth: 30)
            // Icon
            CoinImageView(coin: coin)
                .frame(width: 30, height: 30)
            // Coin symbol
            Text(coin.symbol.uppercased())
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
                .padding(.leading, 6)
            
            Spacer()
            // Current holdings
            if showHoldingsColumn {
                VStack(alignment: .trailing) {
                    Text(coin.currentHoldingValue.asCurrencyWith2Decimals())
                        .bold()
                        .foregroundStyle(Color.theme.accent)
                    
                    Text((coin.currentHoldings ?? 0).asNumberString())
                        .bold()
                        .foregroundStyle(Color.theme.secondaryText)
                }
            }
            // Price & percentage
            VStack(alignment: .trailing) {
                Text("\(coin.currentPrice.asCurrencyWith2Decimals())")
                    .bold()
                    .foregroundStyle(Color.theme.accent)
                
                Text(coin.priceChangePercentage24H?.asPercentString() ?? "")
                    .foregroundStyle(
                        (coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.green : Color.theme.red
                    )
            }
            .frame(width: screenSize.width / 3.5, alignment: .trailing)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    Group {
        CoinRowView(coin: mockCoin1, showHoldingsColumn: true)
        CoinRowView(coin: mockCoin2, showHoldingsColumn: true)
    }
    .environment(\.screenSize, CGSize(width: 402.0, height: 0))
}
