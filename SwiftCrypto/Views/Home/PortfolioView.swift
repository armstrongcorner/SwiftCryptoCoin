//
//  PortfolioView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 26/11/2025.
//

import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var amountHolding: String = ""
    @State private var showCheckmark: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    SearchBarView(searchText: $homeVM.searchText)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    coinLogoList
                    
                    if selectedCoin != nil {
                        portfolioInputSection
                    }
                }
            }
            .background(
                Color.theme.background
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Portfolio")
            .toolbar {
                toolbarSection
            }
            .onChange(of: homeVM.searchText) { _, newValue in
                if newValue.isEmpty {
                    removeSelectedCoin()
                }
            }
        }
    }
}

// MARK: - UI extension
extension PortfolioView {
    @ToolbarContentBuilder
    private var toolbarSection: some ToolbarContent {
        // close btn
        ToolbarItem(placement: .topBarLeading) {
            CloseButton()
        }
        
        // save btn
        if selectedCoin != nil && selectedCoin?.currentHoldings != Double(amountHolding) {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if !showCheckmark {
                        Button {
                            saveBtnPressed()
                        } label: {
                            Text("Save".uppercased())
                        }
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundStyle(Color.theme.accent)
            }
        }
    }
    
    private var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach((homeVM.searchText.isEmpty && !homeVM.portfolioCoins.isEmpty) ? homeVM.portfolioCoins : homeVM.allCoins) { coinModel in
                    CoinLogoView(coinModel: coinModel)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                updateSelectedCoin(coin: coinModel)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedCoin?.id == coinModel.id ? Color.theme.green : .clear, lineWidth: 1)
                        )
                }
            }
            .frame(height: 120)
            .padding(.horizontal, 1)
        }
        .padding()
    }
    
    private func updateSelectedCoin(coin: CoinModel) {
        selectedCoin = coin
        
        if let portfolioCoin = homeVM.portfolioCoins.first(where: { $0.id == coin.id }),
           let amount = portfolioCoin.currentHoldings {
            amountHolding = "\(amount)"
        } else {
            amountHolding = ""
        }
    }
    
    private var portfolioInputSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text("\(selectedCoin?.currentPrice.asCurrencyWith2Decimals() ?? "")")
            }
            
            Divider()
            
            HStack {
                Text("Amount holding:")
                Spacer()
                TextField("Ex: 1.4", text: $amountHolding)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            
            Divider()
            
            HStack {
                Text("Current value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
        }
        .animation(.none, value: selectedCoin?.id)
        .padding()
        .font(.headline)
        .foregroundStyle(Color.theme.accent)
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(amountHolding) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        
        return 0
    }
    
    private func saveBtnPressed() {
        guard let selectedCoin, let amount = Double(amountHolding) else {
            return
        }
        
        // save to portfolio
        homeVM.updatePortfolio(coin: selectedCoin, amount: amount)
        
        // show checkmark
        withAnimation(.easeIn) {
            showCheckmark = true
//            removeSelectedCoin()
        }
        
        // hide keyboard
        UIApplication.shared.endEditing()
        
        // hide checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeOut) {
                showCheckmark = false
                removeSelectedCoin()
            }
        }
    }
    
    private func removeSelectedCoin() {
        selectedCoin = nil
        amountHolding = ""
        homeVM.searchText = ""
    }
}

// MARK: - Previews
#Preview {
    PortfolioView()
        .environmentObject(mockHomeVM)
}
