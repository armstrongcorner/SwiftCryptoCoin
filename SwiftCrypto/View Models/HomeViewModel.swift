//
//  HomeViewModel.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 22/11/2025.
//

import Foundation
import Combine
import SwiftUI

enum SortOption {
    case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var homeStats: [StatisticModel] = []
    
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holdings
    @Published var isLoading: Bool = false
    @Published var errMsg: String? = nil
    
    private let coinDataService: CoinDataServiceProtocol
    private let marketDataService: MarketDataServiceProtocol
    var portfolioDataService: PortfolioDataService
    
    private var cancellables = Set<AnyCancellable>()
    
    private let reloadTrigger = PassthroughSubject<Void, Never>()
    
    init(
        coinDataService: CoinDataServiceProtocol = CoinDataService(),
        marketDataService: MarketDataServiceProtocol = MarketDataService(),
        portfolioDataService: PortfolioDataService = PortfolioDataService()
    ) {
        self.coinDataService = coinDataService
        self.marketDataService = marketDataService
        self.portfolioDataService = portfolioDataService
        
        addSubscribers()
    }
    
    func addSubscribers() {
        isLoading = true
        errMsg = nil
        
        // get,filter and sort allCoins
        reloadTrigger
            .prepend(())
            .flatMap { [weak self] _ -> AnyPublisher<[CoinModel], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.coinDataService.getCoins()
                    .catch { [weak self] error -> Just<[CoinModel]> in
                        self?.errMsg = error.localizedDescription
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .share()
            .prepend([])
            .combineLatest($searchText, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                self?.isLoading = false
                self?.allCoins = coins
            }
            .store(in: &cancellables)
        
        // get portfolio data
        $allCoins.combineLatest(portfolioDataService.$portfolioEntities)
            .map(mapPortfolioData)
            .sink { [weak self] returnedCoins in
                guard let self else { return }
                self.portfolioCoins = self.sortPortfolioCoins(portfolioCoins: returnedCoins)
            }
            .store(in: &cancellables)

        // get market data
        reloadTrigger
            .prepend(())
            .flatMap { [weak self] _ -> AnyPublisher<MarketDataModel?, Never> in
                guard let self else {
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
                return self.marketDataService.getMarketData()
                    .catch { [weak self] error -> Just<MarketDataModel?> in
                        self?.errMsg = error.localizedDescription
                        return Just(nil)
                    }
                    .eraseToAnyPublisher()
            }
            .prepend(nil)
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedHomeStats in
                self?.isLoading = false
                self?.homeStats = returnedHomeStats
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData() {
        isLoading = true
        errMsg = nil
        reloadTrigger.send(())

        HapticManager.instance.notification(type: .success)
    }
    
    // MARK: - Private functions
    private func filterAndSortCoins(allCoins: [CoinModel], searchText: String, sort: SortOption) -> [CoinModel] {
        var updatedCoins = filterCoins(searchText: searchText, allCoins: allCoins)
        sortAllCoins(sort: sort, coins: &updatedCoins)
        
        return updatedCoins
    }
    
    private func filterCoins(searchText: String, allCoins: [CoinModel]) -> [CoinModel] {
        guard !searchText.isEmpty else {
            return allCoins
        }
        
        let lowerCasedText = searchText.lowercased()
        
        return allCoins.filter {
            $0.name.lowercased().contains(lowerCasedText)
            || $0.id.lowercased().contains(lowerCasedText)
            || $0.symbol.lowercased().contains(lowerCasedText)
        }
    }
    
    private func sortAllCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort {
        case .rank, .holdings:
            coins.sort { $0.rank < $1.rank }
        case .rankReversed, .holdingsReversed:
            coins.sort { $0.rank > $1.rank }
        case .price:
            coins.sort { $0.currentPrice > $1.currentPrice }
        case .priceReversed:
            coins.sort { $0.currentPrice < $1.currentPrice }
        }
    }
    
    private func sortPortfolioCoins(portfolioCoins: [CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .holdings:
            return portfolioCoins.sorted { $0.currentHoldingValue > $1.currentHoldingValue }
        case .holdingsReversed:
            return portfolioCoins.sorted { $0.currentHoldingValue < $1.currentHoldingValue }
        default:
            return portfolioCoins
        }
    }
    
    private func mapPortfolioData(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
        return allCoins.compactMap { coin -> CoinModel? in
            guard let portfolioEntity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                return nil
                
            }
            return coin.updateHoldings(amount: portfolioEntity.amount)
        }
    }
    
    private func mapGlobalMarketData(marketData: MarketDataModel?, portfilioData: [CoinModel]) -> [StatisticModel] {
        var stats: [StatisticModel] = []
        
        guard let data = marketData else {
            return stats
        }
        
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        let totalPortfolioValue = portfilioData.reduce(0) { partialResult, nextPortfolioItem in
            partialResult + nextPortfolioItem.currentHoldingValue
        }
        let previousPortfolioValue = portfilioData.reduce(0) { partialResult, nextPortfolioItem in
            let currentValue = nextPortfolioItem.currentHoldingValue
            let percentageChange = (nextPortfolioItem.priceChangePercentage24H ?? 0) / 100
            let previousValue = currentValue / (1 + percentageChange)
            return partialResult + previousValue
        }
        let percentageChange = (totalPortfolioValue - previousPortfolioValue) / previousPortfolioValue * 100
        let portfolio = StatisticModel(title: "Portfolio Value", value: totalPortfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        
        return stats
    }
}
