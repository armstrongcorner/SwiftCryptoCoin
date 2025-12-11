//
//  CoinDetailDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 01/12/2025.
//

import Foundation
import Combine

protocol CoinDetailDataServiceProtocol {
    func getCoinDetail(by coinId: String)
}

class CoinDetailDataService: CoinDetailDataServiceProtocol {
    private let networkingManager: NetworkingManagerProtocol
    @Published var coinDetail: CoinDetailModel? = nil
    
    var coinDetailSubscription: AnyCancellable?
    
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    func getCoinDetail(by coinId: String) {
        do {
            let urlString = "https://api.coingecko.com/api/v3/coins/\(coinId)"
            
            coinDetailSubscription = try networkingManager.request(urlString: urlString, method: .get, headers: ["x-cg-demo-api-key" : Constants.authToken])
                .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] coinDetail in
                    self?.coinDetail = coinDetail
                    self?.coinDetailSubscription?.cancel()
                })
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
}
