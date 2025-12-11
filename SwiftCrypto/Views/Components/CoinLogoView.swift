//
//  CoinLogoView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 26/11/2025.
//

import SwiftUI

struct CoinLogoView: View {
    let coinModel: CoinModel
    
    var body: some View {
        VStack {
            CoinImageView(coin: coinModel)
                .frame(width: 50, height: 50)
            
            Text(coinModel.symbol.uppercased())
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .bold()
            
            Text(coinModel.name)
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CoinLogoView(coinModel: mockCoin1)
    
    CoinLogoView(coinModel: mockCoin2)
}
