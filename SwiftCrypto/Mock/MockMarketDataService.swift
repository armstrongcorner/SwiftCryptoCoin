//
//  MockMarketDataService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 12/12/2025.
//

import Foundation
import Combine

class MockMarketDataService: MarketDataServiceProtocol {
    var mockResult: Result<MarketDataModel?, Error>
    
    init(mockResult: Result<MarketDataModel?, Error>) {
        self.mockResult = mockResult
    }
    
    func getMarketData() -> AnyPublisher<MarketDataModel?, Error> {
        return Future<MarketDataModel?, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                promise(self.mockResult)
            }
        }
        .eraseToAnyPublisher()
    }
}
