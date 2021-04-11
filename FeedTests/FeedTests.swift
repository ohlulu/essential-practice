//
//  FeedTests.swift
//  FeedTests
//
//  Created by Ohlulu on 2021/4/5.
//

import Feed
import XCTest

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
                client.complete(withStatusCode: code, data: Data(), at: index)
            }
        }
    }
    
    func test_load_deliverFeedItemOn20HTTPStatusCode() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        let item1 = makeItem(id: UUID(), description: "desc", location: "location", imageURL: URL(string: "https://image-url.com")!)
        
        let item2 = makeItem(id: UUID(), description: nil, location: "location", imageURL: URL(string: "https://image-url.com")!)
        
        let item3 = makeItem(id: UUID(), description: "desc", location: nil, imageURL: URL(string: "https://image-url.com")!)
        
        let item4 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://image-url.com")!)
        
        let items = [item1, item2, item3, item4]
        items.enumerated().forEach { index, item in
            print(item.feed)
            except(sut: sut, to: [.success([item.feed])]) {
                client.complete(withStatusCode: 200, data: item.jsonData, at: index)
            }
        }
    }
    
    // MARK: - Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (feed: FeedItem, jsonData: Data) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "items": [
                [
                    "id": id.uuidString,
                    "description": description,
                    "location": location,
                    "image": imageURL.absoluteString
                ]
            ]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return (item, jsonData)
    }
    
    private func except(sut: RemoteFeedLoader, to completionWithResults: [RemoteFeedLoader.Result], when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load { capturedResult.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResult, completionWithResults, file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var message = [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)]()
        var requestURLs: [URL] { message.map(\.url) }
        
        func send(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            message.append((url, completion))
        }
        
        // - spying behavior
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
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
