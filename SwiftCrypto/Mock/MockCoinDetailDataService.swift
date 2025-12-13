//
//  MockCoinDetailDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 12/12/2025.
//

import Foundation
import Combine

class MockCoinDetailDataService: CoinDetailDataServiceProtocol {
    var mockResult: Result<CoinDetailModel?, Error>
    
    init(mockResult: Result<CoinDetailModel?, Error>) {
        self.mockResult = mockResult
    }
    
    func getCoinDetail(coinId: String) -> AnyPublisher<CoinDetailModel?, Error> {
        return Future<CoinDetailModel?, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                return promise(self.mockResult)
            }
        }
        .eraseToAnyPublisher()
    }
}
