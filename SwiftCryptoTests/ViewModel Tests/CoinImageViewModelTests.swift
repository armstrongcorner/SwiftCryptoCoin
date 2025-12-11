//
//  CoinImageViewModelTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 10/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class CoinImageViewModelTests: XCTestCase {
    private var sut: CoinImageViewModel!
    private var mockImageService: MockImageService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cancellables = []
    }

    override func tearDownWithError() throws {
//        sut = nil
        mockImageService = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testFetchImageAndFinishLoading() throws {
        // given
        mockImageService = MockImageService(mockResult: .success(mockImage1.imageData))
        sut = CoinImageViewModel(coin: mockCoin1, imageService: mockImageService)
        
        let exp = expectation(description: "wait for fetching image...")
        
        // when
        sut.$image
            .dropFirst()
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(sut.errMsg, "Should not return an error.")
        XCTAssertEqual(sut.image, mockImage1.imageData, "Should return and set the fetched image.")
        XCTAssertFalse(sut.isLoading, "Should finish loading state. [\(sut.isLoading)]")
    }
    
    func testFetchImageFailed() throws {
        // given
        mockImageService = MockImageService(mockResult: .failure(NetworkingError.invalidResponse(500)))
        sut = CoinImageViewModel(coin: mockCoin1, imageService: mockImageService)
        
        let exp = expectation(description: "wait for fetching image...")
        
        // when
        sut.$image
            .dropFirst()
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(sut.image, "Should not return an image.")
        XCTAssertNotNil(sut.errMsg, "Should return an error.")
        XCTAssertTrue(sut.errMsg!.contains("500"), "Should contain the error code 500")
        XCTAssertFalse(sut.isLoading, "Should finish loading state. [\(sut.isLoading)]")
    }
}
