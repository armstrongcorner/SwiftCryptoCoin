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
//        sut = nil
        cancellables = nil
        mockNetworkingManager = nil
        
        try super.tearDownWithError()
    }

    func testGetMarketDataSuccess() throws {
        // given
        let globalDataToBinary = try JSONEncoder().encode(mockGlobalData)
        mockNetworkingManager = MockNetworkingManager(mockType: .success(globalDataToBinary))
        sut = MarketDataService(networkingManager: mockNetworkingManager)
        var receivedMarketData: MarketDataModel?
        var receivedError: Error?
        
        let exp = expectation(description: "wait for fetching global market data...")
        
        // when
        sut.getMarketData()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                    XCTFail("Should not have received an error. Received: \(error)")
                }
                
                exp.fulfill()
            } receiveValue: { marketData in
                receivedMarketData = marketData
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(receivedError, "Should not have received an error.")
        XCTAssertEqual(receivedMarketData?.marketCap, mockGlobalData.data?.marketCap, "Received market cap String should be same with computed mock data")
        XCTAssertEqual(receivedMarketData?.volume, mockGlobalData.data?.volume, "Received volume String should be same with computed mock data")
        XCTAssertEqual(receivedMarketData?.btcDominance, mockGlobalData.data?.btcDominance, "Received btc dominance String should be same with computed mock data")
    }
    
    func testGetMarketDataFailed() throws {
        // given
        mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.invalidResponse(500)))
        sut = MarketDataService(networkingManager: mockNetworkingManager)
        var receivedMarketData: MarketDataModel?
        var receivedError: Error?
        
        let exp = expectation(description: "wait for fetching global market data...")
        
        // when
        sut.getMarketData()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                
                exp.fulfill()
            } receiveValue: { marketData in
                receivedMarketData = marketData
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(receivedMarketData, "Should not return any global market data.")
        XCTAssertNotNil(receivedError, "Should return an error.")
        XCTAssertTrue(receivedError!.localizedDescription.contains("500"), "Should return an error with status code 500.")
    }
}
