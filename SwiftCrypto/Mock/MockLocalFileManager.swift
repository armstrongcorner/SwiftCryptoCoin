//
//  MockLocalFileManager.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 09/12/2025.
//

import Foundation
import UIKit

class MockLocalFileManager: LocalFileManagerProtocol {
    var store: [String: UIImage] = [:]
    
    private(set) var saveCalls: [(imageName: String, folderName: String)] = []
    private(set) var getCalls: [(imageName: String, folderName: String)] = []
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        let key = "\(folderName)/\(imageName)"
        saveCalls.append((imageName: imageName, folderName: folderName))
        store[key] = image
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        let key = "\(folderName)/\(imageName)"
        getCalls.append((imageName: imageName, folderName: folderName))
        return store[key]
    }
}
