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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedError: Error {}
    
    func send(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
}

class URLSessionHTTPClient_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_sendURL_performsGETRequestWithURL() {
        let url = anyURL()

        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().send(url: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }

    func test_sendURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receiveError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receiveError?.domain, requestError.domain)
        XCTAssertEqual(receiveError?.code, requestError.code)
    }
    
    func test_sendURL_successWithHTTPResponseAndData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receiveValue = resultValueFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receiveValue?.data, data)
        XCTAssertEqual(receiveValue?.response.url, response.url)
        XCTAssertEqual(receiveValue?.response.statusCode, response.statusCode)
    }
    
    func test_sendURL_allInvalidateCase() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_sendURL_successWithEmptyDataAndHTTPURLResponse() {
        let response = anyHTTPURLResponse()
        
        let receiveValue = resultValueFor(data: nil, response: anyHTTPURLResponse(), error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receiveValue?.data, emptyData)
        XCTAssertEqual(receiveValue?.response.url, response.url)
        XCTAssertEqual(receiveValue?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        var receivedError: Error?
        switch receivedResult {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("expected failure with error \(receivedResult)", file: file, line: line)
        }
        return receivedError
    }
    
    private func resultValueFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        var receivedValue: (data: Data, response: HTTPURLResponse)?
        switch receivedResult {
        case let .success((data, response)):
            receivedValue = (data, response)
        default:
            XCTFail("expected failure with error \(receivedResult)", file: file, line: line)
        }
        return receivedValue
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT()
        var receiveResult: HTTPClient.Result!
        let exp = expectation(description: "wait for completion")
        sut.send(url: anyURL()) { result in
            switch result {
            case let .success((data, response)):
                receiveResult = .success((data, response))
            case let .failure(error):
                receiveResult = .failure(error)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receiveResult
    }
    
    private final class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
