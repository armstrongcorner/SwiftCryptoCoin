//
//  ImageServiceTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 09/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

@MainActor
final class ImageServiceTests: XCTestCase {
    var mockNetworkingManager: MockNetworkingManager!
    var mockLocalFileManager: MockLocalFileManager!
    var sut: ImageService!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        cancellables = []
    }

    override func tearDownWithError() throws {
//        sut = nil
        mockNetworkingManager = nil
        mockLocalFileManager = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testDownloadAndCacheImageSuccess() throws {
        // given
        let imageName = "testImage"
        let folderName = "testFolder"
        var receivedImage: UIImage?
        var receivedError: Error?
        
        mockNetworkingManager = MockNetworkingManager(mockType: .success(mockImage1.imageData.pngData() ?? Data()))
        mockLocalFileManager = MockLocalFileManager()
        
        sut = ImageService(
            folderName: folderName,
            fileManager: mockLocalFileManager,
            networkingManager: mockNetworkingManager,
        )
        
        let exp = expectation(description: "wait for fetching image from local or remote...")
        
        // when
        sut.getCoinImage(urlString: mockImage1.urlString, imageName: imageName)
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                    XCTFail("Should not receive an error")
                }
                exp.fulfill()
            } receiveValue: { img in
                receivedImage = img
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)

        // then
        XCTAssertNil(receivedError, "Should not receive an error when downloading and caching the image.")
        XCTAssertNotNil(receivedImage, "Should fetch and set the image.")
        XCTAssertEqual(mockNetworkingManager.lastRequest?.urlString, mockImage1.urlString, "Should download the image from network.")
        XCTAssertEqual(mockLocalFileManager.saveCalls.count, 1, "Should save the downloaded image.")
        XCTAssertEqual(mockLocalFileManager.store["\(folderName)/\(imageName)"], receivedImage, "Should save the correct image.")
    }
    
    func testGetImageFromCacheOnlySuccess() throws {
        // given
        let imageName = "testImage"
        let folderName = "testFolder"
        var receivedImage: UIImage?
        var receivedError: Error?
        
        mockNetworkingManager = MockNetworkingManager()
        mockLocalFileManager = MockLocalFileManager()
        mockLocalFileManager.store = ["\(folderName)/\(imageName)": mockImage1.imageData]
        
        sut = ImageService(
            folderName: folderName,
            fileManager: mockLocalFileManager,
            networkingManager: mockNetworkingManager,
        )
        
        let exp = expectation(description: "wait for fetching image from local or remote...")
        
        // when
        sut.getCoinImage(urlString: mockImage1.urlString, imageName: imageName)
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                    XCTFail("Should not receive an error")
                }
                exp.fulfill()
            } receiveValue: { img in
                receivedImage = img
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(receivedError, "Should not receive an error when downloading and caching the image.")
        XCTAssertNotNil(receivedImage, "Should fetch and set the image.")
        XCTAssertEqual(mockLocalFileManager.getCalls.count, 1, "Should try to get the image from the cache.")
        XCTAssertEqual(mockLocalFileManager.saveCalls.count, 0, "Should not try to save the image.")
        XCTAssertNil(mockNetworkingManager.lastRequest, "Should not try to fetch the image from the network.")
    }

    func testDownloadImageFailed() throws {
        // given
        let imageName = "testImage"
        let folderName = "testFolder"
        var receivedImage: UIImage?
        var receivedError: Error?
        
        mockNetworkingManager = MockNetworkingManager(mockType: .failure(NetworkingError.invalidResponse(500)))
        mockLocalFileManager = MockLocalFileManager()
        
        sut = ImageService(
            folderName: folderName,
            fileManager: mockLocalFileManager,
            networkingManager: mockNetworkingManager,
        )
        
        let exp = expectation(description: "wait for fetching image from local or remote...")
        
        // when
        sut.getCoinImage(urlString: mockImage1.urlString, imageName: imageName)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                
                exp.fulfill()
            } receiveValue: { img in
                receivedImage = img
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
        
        // then
        XCTAssertNil(receivedImage, "Should not receive image.")
        XCTAssertNotNil(receivedError, "Should receive an error when downloading and caching the image.")
        XCTAssertTrue(receivedError!.localizedDescription.contains("500"), "Should receive an error with status code 500.")
        XCTAssertEqual(mockLocalFileManager.getCalls.count, 1, "Should try to get the image from local file once.")
        XCTAssertEqual(mockLocalFileManager.saveCalls.count, 0, "Should not try to cache the image because downloading failed.")
    }
}
