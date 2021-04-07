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

        client.error = NSError()
        
        var capturedError: RemoteFeedLoader.Error?
        sut.load { error in
            capturedError = error
        }

        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK: - Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class MockHTTPClient: HTTPClient {
        var requestURLs: [URL] = []
        var error: Error?
        
        func send(url: URL, completion: (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestURLs.append(url)
        }
        
    }
}
