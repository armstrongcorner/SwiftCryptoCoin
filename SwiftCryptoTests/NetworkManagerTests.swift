//
//  NetworkManagerTests.swift
//  SwiftCryptoTests
//
//  Created by Armstrong Liu on 07/12/2025.
//

import XCTest
import Combine
@testable import SwiftCrypto

// 1) 用 URLProtocol 拦截请求并返回自定义响应
final class MockURLProtocol: URLProtocol {
    // 每个测试用例按需设置这个闭包，来决定返回什么
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    // 记录最近一次请求，便于断言 headers/method/timeout 等
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            Self.lastRequest = request
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class NetworkingManagerTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var session: URLSession!
    private var sut: NetworkingManager!

    override func setUp() {
        super.setUp()
        cancellables = []

        // 2) 用 MockURLProtocol 构造一个独立的 URLSession
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        // 3) 把这个 session 注入到被测的 actor
        sut = NetworkingManager(urlSession: session)
    }

    override func tearDown() {
        cancellables = nil
        session = nil
        sut = nil
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.lastRequest = nil
        super.tearDown()
    }

    func test_request_success_returnsData() async throws {
        // given
        let expected = Data(#"{"ok":true}"#.utf8)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!
            return (response, expected)
        }

        let exp = expectation(description: "wait for publisher")

        // when
        let publisher = try await sut.request(urlString: "https://example.com/success", method: .get)

        var received: Data?
        publisher
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
                exp.fulfill()
            } receiveValue: { data in
                received = data
            }
            .store(in: &cancellables)

        await fulfillment(of: [exp], timeout: 1.0)

        // then
        XCTAssertEqual(received, expected)
        XCTAssertEqual(MockURLProtocol.lastRequest?.httpMethod, "GET")
    }

    func test_request_invalidURL_throws() async {
        do {
            _ = try await sut.request(urlString: "invalid url", method: .get)
            XCTFail("Expected to throw invalidUrl")
        } catch let NetworkingError.invalidUrl(badUrlString) {
            XCTAssertTrue(badUrlString == "invalid url")
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    func test_request_non2xx_failsWithInvalidResponse() async throws {
        // given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        let exp = expectation(description: "wait for failure")

        // when
        let publisher = try await sut.request(urlString: "https://example.com/server-error", method: .get)

        var receivedError: Error?
        publisher
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                exp.fulfill()
            } receiveValue: { _ in
                XCTFail("Should not emit value on 500")
            }
            .store(in: &cancellables)

        await fulfillment(of: [exp], timeout: 1.0)

        // then
        if case .invalidResponse(let code)? = (receivedError as? NetworkingError) {
            XCTAssertEqual(code, 500)
        } else {
            XCTFail("Expected NetworkingError.invalidResponse, got \(String(describing: receivedError))")
        }
    }

    func test_request_appliesHeadersMethodAndTimeout() async throws {
        // given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        let headers = ["X-Test": "123"]

        let exp = expectation(description: "wait for publisher")

        // when
        let publisher = try await sut.request(
            urlString: "https://example.com/check",
            method: .post,
            headers: headers,
            timeout: 5
        )

        publisher
            .sink { _ in exp.fulfill() } receiveValue: { _ in }
            .store(in: &cancellables)

        await fulfillment(of: [exp], timeout: 1.0)

        // then
        let req = MockURLProtocol.lastRequest
        XCTAssertEqual(req?.httpMethod, "POST")
        XCTAssertEqual(req?.value(forHTTPHeaderField: "X-Test"), "123")
        XCTAssertEqual(req?.timeoutInterval ?? 0, 5, accuracy: 0.01)
    }
}

