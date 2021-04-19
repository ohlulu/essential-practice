//
//  URLSessionHTTPClient_Tests.swift
//  FeedTests
//
//  Created by Ohlulu on 2021/4/19.
//

import Feed
import XCTest

class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func send(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClient_Tests: XCTestCase {

    func test_sendURL_createsDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.send(url: url) { _ in }
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_sendURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.send(url: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private final class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        var stubs = [URL: URLSessionDataTask]()

        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}
