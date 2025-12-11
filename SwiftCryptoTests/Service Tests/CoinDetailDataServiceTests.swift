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
        
        try super.tearDownWithError()
    }

    func testGetCoinDetailSuccess() throws {
        // given
        let mockCoinDetailToData = try JSONEncoder().encode(mockCoinDetail)
        mockNetworkingManager = MockNetworkingManager(mockType: .success(mockCoinDetailToData))
        sut = CoinDetailDataService(networkingManager: mockNetworkingManager)
        var received: CoinDetailModel?
        
        let exp = expectation(description: "wait for fetching coin detail...")
        
        // when
        sut.getCoinDetail(by: mockCoinDetail.id ?? "")
        sut.$coinDetail
            .dropFirst()
            .sink { coinDetail in
                received = coinDetail
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertEqual(mockCoinDetail.id, received?.id, "Received coin detail id should match the expected one")
        XCTAssertEqual(mockCoinDetail.description?.en, received?.description?.en, "Received coin detail description should match the expected one")
    }
    
    func testGetCoinDetailFailure() throws {
        // given
        mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.unknown))
        sut = CoinDetailDataService(networkingManager: mockNetworkingManager)
        var received: CoinDetailModel?
        
        let exp = expectation(description: "wait for fetching coin detail...")
        exp.isInverted = true
        
        // when
        sut.getCoinDetail(by: mockCoinDetail.id ?? "")
        sut.$coinDetail
            .dropFirst()
            .sink { coinDetail in
                received = coinDetail
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(received, "Should not return any data.")
    }
}
