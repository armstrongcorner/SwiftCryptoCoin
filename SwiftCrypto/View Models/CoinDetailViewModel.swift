//
//  CoinDetailViewModel.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 01/12/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CoinDetailViewModel: ObservableObject {
    @Published var overviewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var description: String? = nil
    @Published var homePageUrlString: String? = nil
    @Published var subredditUrlString: String? = nil
    
    @Published var isLoading: Bool = false
    @Published var errMsg: String? = nil
    
    let coin: CoinModel
    private let coinDetailDataService: CoinDetailDataServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, coinDetailDataService: CoinDetailDataServiceProtocol = CoinDetailDataService()) {
        self.coin = coin
        self.coinDetailDataService = coinDetailDataService
        
        addSubscribers()
    }
    
    private func addSubscribers() {
        isLoading = true
        errMsg = nil
        
        // Make the shared publisher
        let sharedPublisher = coinDetailDataService.getCoinDetail(coinId: coin.id)
            .share()
            .eraseToAnyPublisher()
        
        sharedPublisher
            .map { [weak self] detail -> (overview: [StatisticModel], additional: [StatisticModel]) in
                guard let self else {
                    return (overview: [], additional: [])
                }
                return self.mapDetailsToStatistics(coinDetailModel: detail)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errMsg = error.localizedDescription
                    
                    self.overviewStatistics = []
                    self.additionalStatistics = []
                }
            } receiveValue: { [weak self] (overview: [StatisticModel], additional: [StatisticModel]) in
                guard let self else { return }
                self.isLoading = false
                self.overviewStatistics = overview
                self.additionalStatistics = additional
            }
            .store(in: &cancellables)
        
        sharedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errMsg = error.localizedDescription
                    
                    self.description = nil
                    self.homePageUrlString = nil
                    self.subredditUrlString = nil
                }
            } receiveValue: { [weak self] coinDetail in
                guard let self else { return }
                self.isLoading = false
                self.description = coinDetail?.description?.en
                self.homePageUrlString = coinDetail?.links?.homepage?.first
                self.subredditUrlString = coinDetail?.links?.subredditURL
            }
            .store(in: &cancellables)
    }
    
    private func mapDetailsToStatistics(coinDetailModel: CoinDetailModel?) -> (overview: [StatisticModel], additional: [StatisticModel]) {
        // overview
        let price = self.coin.currentPrice.asCurrencyWith6Decimals()
        let priceChangePercentage = self.coin.priceChangePercentage24H
        let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: priceChangePercentage)
        
        let marketCap = "$\(self.coin.marketCap?.formattedWithAbbreviations() ?? "")"
        let marketCapChangePercentage = self.coin.marketCapChangePercentage24H
        let marketStat = StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketCapChangePercentage)
        
        let rank = "\(self.coin.rank)"
        let rankStat = StatisticModel(title: "Rank", value: rank)
        
        let volume = "$\(self.coin.totalVolume?.formattedWithAbbreviations() ?? "")"
        let volumeStat = StatisticModel(title: "Volume", value: volume)
        
        let overviewArray: [StatisticModel] = [priceStat, marketStat, rankStat, volumeStat]
        
        // additional
        let high = self.coin.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = StatisticModel(title: "24h High", value: high)
        
        let low = self.coin.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = StatisticModel(title: "24h Low", value: low)
        
        let priceChagne = self.coin.priceChange24H?.asCurrencyWith2Decimals() ?? "n/a"
        let priceChangeStat = StatisticModel(title: "24h Price Change", value: priceChagne, percentageChange: priceChangePercentage)
        
        let marketCapChange = "$\(self.coin.marketCapChange24H?.formattedWithAbbreviations() ?? "")"
        let marketCapChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketCapChangePercentage)
        
        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime) min"
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetailModel?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
        
        let additionalArray = [highStat, lowStat, priceChangeStat, marketCapChangeStat, blockStat, hashingStat]
        
        return (overview: overviewArray, additional: additionalArray)
    }
}
