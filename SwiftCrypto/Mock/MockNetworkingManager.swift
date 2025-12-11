//
//  MockNetworkingManager.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 07/12/2025.
//

import Foundation
import Combine

class MockNetworkingManager: NetworkingManagerProtocol {
    enum MockType {
        case success(Data)
        case failure(Error)
    }
    
    var mockType: MockType
    private(set) var lastRequest: (urlString: String, method: HttpMethod, headers: [String: String]?, timeout: TimeInterval?)?
    
    init(mockType: MockType = .failure(NetworkingError.unknown)) {
        self.mockType = mockType
    }
    
    func request(
        urlString: String,
        method: HttpMethod,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) throws -> AnyPublisher<Data, Error> {
        lastRequest = (urlString, method, headers, timeout)
        
        switch mockType {
        case .success(let data):
            return Just(data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: Data.self, failure: error)
                .eraseToAnyPublisher()
        }
    }
}
