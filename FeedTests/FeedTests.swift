//
//  FeedTests.swift
//  FeedTests
//
//  Created by Ohlulu on 2021/4/5.
//

import XCTest

class RemoteFeedLoader {
    
    var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(url: URL) {
        client.requestURL = url
    }
}

protocol HTTPClient {
    var requestURL: URL? { get set }
}

class FeedTests: XCTestCase {

    func test_init_clientDoesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()

        sut.load(url: url)

        XCTAssertEqual(client.requestURL, url)
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(client: client)
        return (sut, client)
    }
    
    private class MockHTTPClient: HTTPClient {
        var requestURL: URL?
    }
}
