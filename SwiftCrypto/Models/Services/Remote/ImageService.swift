//
//  ImageService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 23/11/2025.
//

import Foundation
import SwiftUI
import Combine

protocol ImageServiceProtocol {
    func getCoinImage(urlString: String, imageName: String) -> AnyPublisher<UIImage?, Error>
}

class ImageService: ImageServiceProtocol {
    private let fileManager: LocalFileManagerProtocol
    private let networkingManager: NetworkingManagerProtocol
    private var folderName: String
    private var imageSubscription: AnyCancellable?
    
    init(
        folderName: String = "coin_images",
        fileManager: LocalFileManagerProtocol = LocalFileManager.instance,
        networkingManager: NetworkingManagerProtocol = NetworkingManager()
    ) {
        self.folderName = folderName
        self.fileManager = fileManager
        self.networkingManager = networkingManager
    }
    
    func getCoinImage(urlString: String, imageName: String) -> AnyPublisher<UIImage?, Error> {
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: self.folderName) {
            print("Retrieved image from cache. \(imageName)")
            return Just(savedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            print("Downloading image...\(imageName)")
            return downloadCoinImage(urlString: urlString, imageName: imageName)
        }
    }
    
    private func downloadCoinImage(urlString: String, imageName: String) -> AnyPublisher<UIImage?, Error> {
        do {
            let publisher = try networkingManager.request(urlString: urlString, method: .get)
                .tryMap{ [weak self] data -> UIImage? in
                    let img = UIImage(data: data)
                    if let img, let self {
                        self.fileManager.saveImage(image: img, imageName: imageName, folderName: self.folderName)
                        
                    }
                    return img
                }
                .eraseToAnyPublisher()
            
            return publisher
        } catch (let error) {
            print(error.localizedDescription)
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
