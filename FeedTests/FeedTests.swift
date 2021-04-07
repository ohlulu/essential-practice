//
//  FeedTests.swift
//  FeedTests
//
//  Created by Ohlulu on 2021/4/5.
//

import XCTest
import Feed

class FeedTests: XCTestCase {

    func test_init_clientDoesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestURLs.count, 2)
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliverErrorOnClientError() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        client.complete(with: NSError())

        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_loadTwice_deliverErrorOnClientErrorTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load { capturedErrors.append($0) }
        client.complete(with: NSError())
        
        sut.load { capturedErrors.append($0) }
        client.complete(with: NSError())

        XCTAssertEqual(capturedErrors, [.connectivity, .connectivity])
    }
    
    func test_load_deliverErrorOnNon200HTTPStatusCode() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        let sample = [199, 200, 201, 300, 400, 500]
        sample.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // MARK: - Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class MockHTTPClient: HTTPClient {
        
        var message = [(url: URL, completion: (Result<HTTPURLResponse, Error>) -> Void)]()
        var requestURLs: [URL] { message.map { $0.url } }
        
        func send(url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
            message.append((url, completion))
        }
        
        // - mock behavior
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: message[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            message[index].completion(.success(response))
        }
    }
}
