//
//  CoinDataServiceTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 07/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class CoinDataServiceTests: XCTestCase {
    private var mockNetworkingManager: MockNetworkingManager!
    private var sut: CoinDataService!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil
        
        try super.tearDownWithError()
    }

    func testGetCoinListSuccess() throws {
        // given
        let mockCoinListToData = try JSONEncoder().encode([mockCoin1, mockCoin2])
        mockNetworkingManager = MockNetworkingManager(mockType: .success(mockCoinListToData))
        sut = CoinDataService(networkingManager: mockNetworkingManager)
        var received: [CoinModel] = []
        
        let exp = expectation(description: "wait for fetching coin list...")
        
        // when
        sut.$allCoins
            .dropFirst()
            .sink { coins in
                received = coins
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertEqual(received.count, 2, "Received coin list count should be 2")
        XCTAssertEqual(received.first?.id, mockCoin1.id, "Should match the first id")
        
        XCTAssertEqual(mockNetworkingManager.lastRequest?.method, .get, "Should perform a GET request")
        XCTAssertEqual(mockNetworkingManager.lastRequest?.headers?["x-cg-demo-api-key"], Constants.authToken, "Should include the token in the header")
    }
    
    func testGetCoinListFailure() throws {
        // given
        let mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.invalidResponse(500)))
        sut = CoinDataService(networkingManager: mockNetworkingManager)
        var received: [CoinModel] = []
        
        let exp = expectation(description: "wait for fetching coin list...")
        exp.isInverted = true
        
        // when
        sut.$allCoins
            .dropFirst()
            .sink { coins in
                received = coins
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertTrue(received.isEmpty, "Received coin list count should be empty")
    }
}
