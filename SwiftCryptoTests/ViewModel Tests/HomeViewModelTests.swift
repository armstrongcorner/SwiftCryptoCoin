//
//  HomeViewModelTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 13/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!
    private var mockCoinDataService: MockCoinDataService!
    private var mockMarketDataService: MockMarketDataService!
    private var mockPortfolioDataService: PortfolioDataService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cancellables = []
        mockPortfolioDataService = PortfolioDataService(inMemory: true)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        mockCoinDataService = nil
        mockMarketDataService = nil
        mockPortfolioDataService = nil
        
        
        try super.tearDownWithError()
    }

    func testGetAllCoinsSuccess() throws {
        // given
        mockCoinDataService = MockCoinDataService(mockResult: .success([mockCoin1, mockCoin2]))
        mockMarketDataService = MockMarketDataService(mockResult: .success(nil))
        mockPortfolioDataService = PortfolioDataService(inMemory: true)
        
        sut = HomeViewModel(
            coinDataService: mockCoinDataService,
            marketDataService: mockMarketDataService,
            portfolioDataService: mockPortfolioDataService
        )
        
        let exp = expectation(description: "Wait for fetching all data...")
        
        // when
        sut.$allCoins
            .dropFirst()
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNotNil(sut.allCoins, "Should get all coins")
    }
//    
//    func testSearchFromAllCoinsSuccess() throws {
//        // given
//        
//        // when
//        sut.searchText = "BTC"
//        
//        // then
//    }
}
