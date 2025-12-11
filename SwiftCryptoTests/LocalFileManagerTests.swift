//
//  LocalFileManagerTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 09/12/2025.
//

import XCTest
@testable import SwiftCrypto

@MainActor
final class LocalFileManagerTests: XCTestCase {
    var sut: LocalFileManager!
    private var tempDirUrl: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        tempDirUrl = FileManager.default.temporaryDirectory
            .appending(path: "LocalFileManagerTests")
            .appending(path: UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDirUrl, withIntermediateDirectories: true)
        } catch {
            XCTFail("Failed to create temp directory: \(error)")
        }
        
        sut = LocalFileManager(baseDirectory: tempDirUrl)
    }

    override func tearDownWithError() throws {
        if let tempDirUrl {
            do {
                try FileManager.default.removeItem(at: tempDirUrl)
            } catch {
                XCTFail("Failed to clean up temp directory: \(error)")
            }
        }
        
        tempDirUrl = nil
//        sut = nil

        try super.tearDownWithError()
    }

    func testSaveAndLoadImageSuccess() throws {
        // given
        let imageName = "testImage"
        let folderName = "testImageFolder"
        
        let render = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let testImage = render.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        
        
        // when
        sut.saveImage(image: testImage, imageName: imageName, folderName: folderName)
        let loadedImage = sut.getImage(imageName: imageName, folderName: folderName)
        
        // then
        XCTAssertNotNil(loadedImage, "Should load the image.")
        
        let originalImageDataSize = testImage.pngData()?.count
        let loadedImageDataSize = loadedImage?.pngData()?.count
        XCTAssertEqual(originalImageDataSize, loadedImageDataSize, "Saved and loaded image data count should be the same.")
    }
    
    func testSaveAndLoadImageFail() throws {
        // given
        let imageName = "testImage"
        let folderName = "testImageFolder"
        
        // when
        let loadedImage = sut.getImage(imageName: imageName, folderName: folderName)
        
        // then
        XCTAssertNil(loadedImage, "Should not load the image as it was never saved.")
    }
}
