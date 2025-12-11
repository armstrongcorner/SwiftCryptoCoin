//
//  MarketDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 26/11/2025.
//

import Foundation
import Combine

protocol MarketDataServiceProtocol {
    func getMarketData()
}

class MarketDataService: MarketDataServiceProtocol {
    private let networkingManager: NetworkingManagerProtocol
    @Published var marketData: MarketDataModel? = nil
    
    var marketDataSubscription: AnyCancellable?
    
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
        getMarketData()
    }
    
    func getMarketData() {
        let urlString = "https://api.coingecko.com/api/v3/global"
        
        do {
            marketDataSubscription = try networkingManager.request(urlString: urlString, method: .get, headers: ["x-cg-demo-api-key" : Constants.authToken])
                .decode(type: GlobalData.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] returnedGlobalData in
                    self?.marketData = returnedGlobalData.data
                    self?.marketDataSubscription?.cancel()
                })
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
}
