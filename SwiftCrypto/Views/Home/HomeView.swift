//
//  HomeView.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 22/11/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var homeVM: HomeViewModel
    @State private var showPortfolio: Bool = false
    @State private var showPortfolioView: Bool = false
    @State private var showInfoView: Bool = false
    
    var body: some View {
        ZStack {
            // background layer
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView) {
                    PortfolioView()
                        .presentationSizing(.page)
                }
                .sheet(isPresented: $showInfoView) {
                    InfoView()
                        .presentationSizing(.page)
                }
            
            // content layer
            VStack {
                homeHeader
                
                HomeStatView(showPortfolio: $showPortfolio)
                
                SearchBarView(searchText: $homeVM.searchText)
                    .padding()
                
                columnTitles
                
                if !showPortfolio {
                    allCoinList
                } else {
                    ZStack {
                        if homeVM.portfolioCoins.isEmpty && homeVM.searchText.isEmpty {
                            Text("You haven't added any coins to your portfolio yet. Click the ➕ button on the top left corner to get started! 🧐")
                                .font(.callout)
                                .foregroundStyle(Color.theme.accent)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(50)
                        } else {
                            portfolioCoinList
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - UI extension
extension HomeView {
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: showPortfolio)   // 此处如果使用.animation(.none)，会出现deprecated告警
                .background(
                    CircleButtonAnimationView(isAnimating: $showPortfolio)
                )
                .onTapGesture {
                    if showPortfolio {
                        showPortfolioView.toggle()
                    } else {
                        showInfoView.toggle()
                    }
                }
            
            Spacer()
            
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(Color.theme.accent)
                .animation(.none, value: showPortfolio)
            
            Spacer()
            
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
    private var columnTitles: some View {
        HStack {
            HStack {
                Text("Coin")
                
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: homeVM.sortOption == .rank ? 0.0 : 180.0))
                    .opacity((homeVM.sortOption == .rank || homeVM.sortOption == .rankReversed) ? 1.0 : 0.0)
            }
            .onTapGesture {
                withAnimation(.linear) {
                    homeVM.sortOption = homeVM.sortOption == .rank ? .rankReversed : .rank
                }
            }
            
            Spacer()
            
            if showPortfolio {
                HStack {
                    Text("Holdings")
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(Angle(degrees: homeVM.sortOption == .holdings ? 0.0 : 180.0))
                        .opacity((homeVM.sortOption == .holdings || homeVM.sortOption == .holdingsReversed) ? 1.0 : 0.0)
                }
                .onTapGesture {
                    withAnimation(.linear) {
                        homeVM.sortOption = homeVM.sortOption == .holdings ? .holdingsReversed : .holdings
                    }
                }
            }
            
            HStack {
                Text("Price")
                    .frame(width: screenSize.width / 3.5, alignment: .trailing)
                
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: homeVM.sortOption == .price ? 0.0 : 180.0))
                    .opacity((homeVM.sortOption == .price || homeVM.sortOption == .priceReversed) ? 1.0 : 0.0)
            }
            .onTapGesture {
                withAnimation(.linear) {
                    homeVM.sortOption = homeVM.sortOption == .price ? .priceReversed : .price
                }
            }
            
            Button {
                homeVM.reloadData()
            } label: {
                Image(systemName: "goforward")
                    .symbolEffect(.rotate, options: homeVM.isLoading ? .repeat(.continuous) : .nonRepeating)
            }
            .disabled(homeVM.isLoading)
        }
        .font(.caption)
        .foregroundStyle(Color.theme.secondaryText)
        .padding(.horizontal)
    }
    
    private var allCoinList: some View {
        List {
            ForEach(homeVM.allCoins) { coin in
                NavigationLink(value: coin) {
                    CoinRowView(coin: coin, showHoldingsColumn: false)
                        .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .transition(.move(edge: .leading))
    }
    
    private var portfolioCoinList: some View {
        List {
            ForEach(homeVM.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .listRowBackground(Color.clear)
                
            }
        }
        .listStyle(.plain)
        .transition(.move(edge: .trailing))
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        HomeView()
            .toolbarVisibility(.hidden, for: .navigationBar)
            .navigationDestination(for: CoinModel.self) { coin in
                CoinDetailView(coin: coin)
            }
    }
    .environment(\.screenSize, CGSize(width: 402, height: 0))
    .environmentObject(mockHomeVM)
}
