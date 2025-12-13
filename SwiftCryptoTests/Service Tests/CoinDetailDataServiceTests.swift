//
//  CoinDetailDataServiceTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 08/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class CoinDetailDataServiceTests: XCTestCase {
    private var mockNetworkingManager: MockNetworkingManager!
    private var sut: CoinDetailDataService!
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

    func testGetCoinDetailSuccess() throws {
        // given
        let mockCoinDetailToData = try JSONEncoder().encode(mockCoinDetail)
        mockNetworkingManager = MockNetworkingManager(mockType: .success(mockCoinDetailToData))
        sut = CoinDetailDataService(networkingManager: mockNetworkingManager)
        var receivedCoinDetail: CoinDetailModel?
        var receivedError: Error?
        
        let exp = expectation(description: "wait for fetching coin detail...")
        
        // when
        sut.getCoinDetail(coinId: mockCoinDetail.id ?? "")
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                    XCTFail("Should not have received an error. Received: \(error)")
                }
                exp.fulfill()
            } receiveValue: { detail in
                receivedCoinDetail = detail
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(receivedError, "Should not have received an error.")
        XCTAssertNotNil(receivedCoinDetail, "Should have received a coin detail.")
        XCTAssertEqual(receivedCoinDetail?.id, mockCoinDetail.id, "Received coin detail id should match the expected one")
        XCTAssertEqual(receivedCoinDetail?.description?.en, mockCoinDetail.description?.en, "Received coin detail description should match the expected one")
    }
    
    func testGetCoinDetailFailed() throws {
        // given
        mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.unknown))
        sut = CoinDetailDataService(networkingManager: mockNetworkingManager)
        var receivedCoinDetail: CoinDetailModel?
        var receivedError: Error?
        
        let exp = expectation(description: "wait for fetching coin detail...")
        
        // when
        sut.getCoinDetail(coinId: mockCoinDetail.id ?? "")
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                
                exp.fulfill()
            } receiveValue: { detail in
                receivedCoinDetail = detail
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(receivedCoinDetail, "Should not return any data.")
        XCTAssertNotNil(receivedError, "Should receive an error.")
        XCTAssertTrue(receivedError!.localizedDescription.lowercased().contains("unknown"), "Should receive 'unknown' error.")
    }
}
