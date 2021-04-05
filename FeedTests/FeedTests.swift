//
//  FeedTests.swift
//  FeedTests
//
//  Created by Ohlulu on 2021/4/5.
//

import XCTest

class FeedTests: XCTestCase {

    func test_init_clientDoesNotRequestDataFromURL() {
        let sut = HTTPClient()
        XCTAssertNil(sut.requestURL)
    }
    
    // MARK: - Helper
    
    private class HTTPClient {
        var requestURL: URL?
    }
}
