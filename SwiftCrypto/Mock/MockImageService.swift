//
//  MockImageService.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 10/12/2025.
//

import Foundation
import UIKit
import Combine

class MockImageService: ImageServiceProtocol {
    var mockResult: Result<UIImage?, Error>
    
    init(mockResult: Result<UIImage?, Error>) {
        self.mockResult = mockResult
    }
    
    func getCoinImage(urlString: String, imageName: String) -> AnyPublisher<UIImage?, Error> {
        return Future<UIImage?, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                promise(self.mockResult)
            }
        }
        .eraseToAnyPublisher()
    }
}
