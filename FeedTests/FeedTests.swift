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
        except(sut: sut, to: [.failure(.connectivity)]) {
            client.complete(with: NSError())
        }
    }
    
    func test_loadTwice_deliverErrorOnClientErrorTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        except(sut: sut, to: [.failure(.connectivity), .failure(.connectivity)]) {
            client.complete(with: NSError())
            client.complete(with: NSError())
        }
    }
    
    func test_load_deliverErrorOnNon200HTTPStatusCode() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        let sample = [199, 200, 201, 300, 400, 500]
        sample.enumerated().forEach { index, code in
            except(sut: sut, to: [.failure(.invalidData)]) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    // MARK: - Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func except(sut: RemoteFeedLoader, to completionWithResults: [RemoteFeedLoader.Result], when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load { capturedResult.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResult, completionWithResults, file: file, line: line)
    }
    
    private class MockHTTPClient: HTTPClient {
        
        var message = [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)]()
        var requestURLs: [URL] { message.map { $0.url } }
        
        func send(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            message.append((url, completion))
        }
        
        // - mock behavior
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: message[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            message[index].completion(.success((data, response)))
        }
    }
}
