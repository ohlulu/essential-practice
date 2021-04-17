//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/7.
//

import Foundation

public class RemoteFeedLoader {
    
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
                completion(FeedItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
}
