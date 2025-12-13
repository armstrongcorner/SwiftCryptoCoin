//
//  CoinDetailDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 01/12/2025.
//

import Foundation
import Combine

protocol CoinDetailDataServiceProtocol {
    func getCoinDetail(coinId: String) -> AnyPublisher<CoinDetailModel?, Error>
}

class CoinDetailDataService: CoinDetailDataServiceProtocol {
    private let networkingManager: NetworkingManagerProtocol
    
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    func getCoinDetail(coinId: String) -> AnyPublisher<CoinDetailModel?, Error> {
        do {
            let urlString = "https://api.coingecko.com/api/v3/coins/\(coinId)"
            
            let publisher = try networkingManager.request(urlString: urlString, method: .get, headers: ["x-cg-demo-api-key" : Constants.authToken])
                .decode(type: CoinDetailModel?.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
            
            return publisher
        } catch (let error) {
            print(error.localizedDescription)
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
