//
//  MarketDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 26/11/2025.
//

import Foundation
import Combine

protocol MarketDataServiceProtocol {
    func getMarketData() -> AnyPublisher<MarketDataModel?, Error>
}

class MarketDataService: MarketDataServiceProtocol {
    private let networkingManager: NetworkingManagerProtocol
        
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    func getMarketData() -> AnyPublisher<MarketDataModel?, Error> {
        do {
            let urlString = "https://api.coingecko.com/api/v3/global"
            
            let publisher = try networkingManager.request(urlString: urlString, method: .get, headers: ["x-cg-demo-api-key" : Constants.authToken])
                .decode(type: GlobalData.self, decoder: JSONDecoder())
                .tryMap { globalData -> MarketDataModel? in
                    globalData.data
                }
                .eraseToAnyPublisher()
            return publisher
        } catch (let error) {
            print(error.localizedDescription)
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
