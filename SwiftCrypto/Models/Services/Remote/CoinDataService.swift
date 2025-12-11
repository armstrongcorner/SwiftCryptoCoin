//
//  CoinDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 23/11/2025.
//

import Foundation
import Combine

protocol CoinDataServiceProtocol {
    func getCoins()
}

class CoinDataService {
    private let networkingManager: NetworkingManagerProtocol
    @Published var allCoins: [CoinModel] = []
    
    var coinSubscription: AnyCancellable?
    
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
        self.getCoins()
    }
    
    func getCoins() {
        do {
            let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&price_change_percentage=24h&order=market_cap_desc&per_page=250&page=1&sparkline=true"
            
            coinSubscription = try networkingManager.request(urlString: urlString, method: .get, headers: ["x-cg-demo-api-key" : Constants.authToken])
                .decode(type: [CoinModel].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] coinList in
                    guard let self else { return }
                    self.allCoins = coinList
                    self.coinSubscription?.cancel()
                })
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
}
