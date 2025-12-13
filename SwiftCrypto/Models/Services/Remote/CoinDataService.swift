//
//  CoinDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 23/11/2025.
//

import Foundation
import Combine

protocol CoinDataServiceProtocol {
    func getCoins() -> AnyPublisher<[CoinModel], Error>
}

class CoinDataService: CoinDataServiceProtocol {
    private let networkingManager: NetworkingManagerProtocol
    
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    func getCoins() -> AnyPublisher<[CoinModel], Error> {
        do {
            let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&price_change_percentage=24h&order=market_cap_desc&per_page=250&page=1&sparkline=true"
            let publisher = try networkingManager.request(urlString: urlString, method: .get, headers: ["x-cg-demo-api-key" : Constants.authToken])
                .decode(type: [CoinModel].self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
            
            return publisher
        } catch (let error) {
            print(error.localizedDescription)
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
