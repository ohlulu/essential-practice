//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/7.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    private var client: HTTPClient
    private var url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.send(url: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(tuple):
                let (data, response) = tuple
                completion(RemoteFeedLoader.map(data, from: response))
                
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let remoteFeedItems = try FeedItemMapper.map(data, from: response)
            return .success(remoteFeedItems.toEntities())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    
    func toEntities() -> [FeedItemEntity] {
        return map { FeedItemEntity(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
