//
//  NetworkingManager.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 23/11/2025.
//

import Foundation
import Combine

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkingError: LocalizedError {
    case invalidUrl(String)
    case invalidResponse(Int)
    case httpErrorCode(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse(let statusCode):
            return "Invalid response statusCode: \(statusCode)"
        case .httpErrorCode(let code):
            return "HTTP error code: \(code)"
        case .unknown:
            return "Unknown error"
        }
    }
}

protocol NetworkingManagerProtocol {
    func request(
        urlString: String,
        method: HttpMethod,
        headers: [String: String]?,
        timeout: TimeInterval?
    ) throws -> AnyPublisher<Data, Error>
}

extension NetworkingManagerProtocol {
    func request(
        urlString: String,
        method: HttpMethod,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) throws -> AnyPublisher<Data, Error> {
        try request(urlString: urlString, method: method, headers: headers, timeout: nil)
    }
}

class NetworkingManager: NetworkingManagerProtocol {
    private let urlSession: URLSession
    private let defaultTimeout: TimeInterval = 120
    
    init (urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request(
        urlString: String,
        method: HttpMethod,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) throws -> AnyPublisher<Data, Error> {
        let timeout = timeout ?? defaultTimeout
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else {
            throw NetworkingError.invalidUrl(urlString)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return urlSession.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { try self.handleUrlResponse(output: $0) }
            .eraseToAnyPublisher()
    }
    
    private func handleUrlResponse(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let response = output.response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200..<300).contains(response.statusCode) else {
            throw NetworkingError.invalidResponse(response.statusCode)
        }
        
        return output.data
    }
    
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print("error: \(error.localizedDescription)")
        }
    }
}
