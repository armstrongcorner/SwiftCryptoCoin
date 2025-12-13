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
        mockNetworkingManager = nil
        
        try super.tearDownWithError()
    }

    func testGetCoinListSuccess() throws {
        // given
        let mockCoinListToData = try JSONEncoder().encode([mockCoin1, mockCoin2])
        mockNetworkingManager = MockNetworkingManager(mockType: .success(mockCoinListToData))
        sut = CoinDataService(networkingManager: mockNetworkingManager)
        var receivedCoins: [CoinModel] = []
        var receivedError: Error? = nil
        
        let exp = expectation(description: "wait for fetching coin list...")
        
        // when
        sut.getCoins()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                    XCTFail("Should not have failed with error: \(error)")
                }
                
                exp.fulfill()
            } receiveValue: { coins in
                receivedCoins = coins
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertEqual(receivedCoins.count, 2, "Received coin list count should be 2.")
        XCTAssertEqual(receivedCoins.first?.id, mockCoin1.id, "Should match the first id.")
        XCTAssertNil(receivedError, "Should not have received an error.")
        XCTAssertEqual(mockNetworkingManager.lastRequest?.method, .get, "Should perform a GET request.")
        XCTAssertEqual(mockNetworkingManager.lastRequest?.headers?["x-cg-demo-api-key"], Constants.authToken, "Should include the token in the header")
    }
    
    func testGetCoinListFailed() throws {
        // given
        let mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.invalidResponse(500)))
        sut = CoinDataService(networkingManager: mockNetworkingManager)
        var receivedCoins: [CoinModel] = []
        var receivedError: Error? = nil
        
        let exp = expectation(description: "wait for fetching coin list...")
        
        // when
        sut.getCoins()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                
                exp.fulfill()
            } receiveValue: { coins in
                receivedCoins = coins
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNotNil(receivedError, "Should receive an error.")
        XCTAssertTrue(receivedError!.localizedDescription.contains("500"), "Should receive an error with status code 500.")
        XCTAssertTrue(receivedCoins.isEmpty, "Received coin list count should be empty.")
    }
}
