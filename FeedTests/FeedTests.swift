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
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestURL, url)
    }
    
    // MARK: - Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class MockHTTPClient: HTTPClient {
        var requestURL: URL?
        
        func send(url: URL) {
            requestURL = url
        }
    }
}
