//
//  MarketDataServiceTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 08/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class MarketDataServiceTests: XCTestCase {
    private var mockNetworkingManager: MockNetworkingManager!
    private var sut: MarketDataService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil
        mockNetworkingManager = nil
//        sut = nil
        
        try super.tearDownWithError()
    }

    func testGetMarketDataSuccess() throws {
        // given
        let globalDataToBinary = try JSONEncoder().encode(mockGlobalData)
        mockNetworkingManager = MockNetworkingManager(mockType: .success(globalDataToBinary))
        sut = MarketDataService(networkingManager: mockNetworkingManager)
        var received: MarketDataModel?
        
        let exp = expectation(description: "wait for fetching global market data...")
        
        // when
        sut.$marketData
            .dropFirst()
            .sink { marketData in
                received = marketData
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertEqual(received?.marketCap, mockGlobalData.data?.marketCap, "Received market cap String should be same with computed mock data")
        XCTAssertEqual(received?.volume, mockGlobalData.data?.volume, "Received volume String should be same with computed mock data")
        XCTAssertEqual(received?.btcDominance, mockGlobalData.data?.btcDominance, "Received btc dominance String should be same with computed mock data")
    }
    
    func testGetMarketDataFailure() throws {
        // given
        mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.invalidResponse(500)))
        sut = MarketDataService(networkingManager: mockNetworkingManager)
        var received: MarketDataModel?
        
        let exp = expectation(description: "wait for fetching global market data...")
        exp.isInverted = true
        
        // when
        sut.$marketData
            .dropFirst()
            .sink { marketData in
                received = marketData
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(received, "Should not return any global market data")
    }
}
