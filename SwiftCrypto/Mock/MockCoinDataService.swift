//
//  MockCoinDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 12/12/2025.
//

import Foundation
import Combine

class MockCoinDataService: CoinDataServiceProtocol {
    let mockResult: Result<[CoinModel], Error>
    
    init(mockResult: Result<[CoinModel], Error>) {
        self.mockResult = mockResult
    }
    
    func getCoins() -> AnyPublisher<[CoinModel], Error> {
        return Future<[CoinModel], Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                promise(self.mockResult)
            }
        }
        .eraseToAnyPublisher()
    }
}
