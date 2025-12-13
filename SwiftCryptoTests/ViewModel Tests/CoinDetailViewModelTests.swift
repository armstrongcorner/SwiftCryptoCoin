//
//  CoinDetailViewModelTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 12/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class CoinDetailViewModelTests: XCTestCase {
    private var sut: CoinDetailViewModel!
    private var mockCoinDetailDataService: MockCoinDetailDataService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cancellables = []
    }

    override func tearDownWithError() throws {
//        sut = nil
        mockCoinDetailDataService = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testGetCoinDetailSuccess() throws {
        // given
        mockCoinDetailDataService = MockCoinDetailDataService(mockResult: .success(mockCoinDetail))
        sut = CoinDetailViewModel(coin: mockCoin1, coinDetailDataService: mockCoinDetailDataService)
        
        let exp = expectation(description: "wait for get coin detail data...")
        
        // when
        sut.$overviewStatistics
            .dropFirst()
            .sink { overviewStats in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertFalse(sut.isLoading, "Should finish loading.")
        XCTAssertNil(sut.errMsg, "Should not have error message.")
        XCTAssertGreaterThan(sut.overviewStatistics.count, 0, "Should have overview statistics.")
        XCTAssertGreaterThan(sut.additionalStatistics.count, 0, "Shoud have additional statistics.")
        XCTAssertNotNil(sut.description, "Should have a description.")
    }

    func testGetCoinDetailFailed() throws {
        // given
        mockCoinDetailDataService = MockCoinDetailDataService(mockResult: .failure(NetworkingError.invalidResponse(500)))
        sut = CoinDetailViewModel(coin: mockCoin1, coinDetailDataService: mockCoinDetailDataService)
        
        let exp = expectation(description: "wait for get coin detail data...")
        
        // when
        sut.$overviewStatistics
            .dropFirst()
            .sink { overviewStats in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertFalse(sut.isLoading, "Should finish loading.")
        XCTAssertNotNil(sut.errMsg, "Should have error message.")
        XCTAssertTrue(sut.errMsg!.contains("500"), "Should contain the error code 500.")
        XCTAssertEqual(sut.overviewStatistics.count, 0, "Should not have any overview statistics.")
        XCTAssertEqual(sut.additionalStatistics.count, 0, "Should not have any additional statistics.")
        XCTAssertNil(sut.description, "Should not have a description.")
    }
}
