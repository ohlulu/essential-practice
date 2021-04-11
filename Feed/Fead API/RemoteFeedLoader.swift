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
    
    public typealias Result = Swift.Result<[FeedItemEntity], Error>
    
    private var client: HTTPClient
    private var url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.send(url: url) { result in
            switch result {
            case let .success((data, _)):
                do {
                    let dto = try JSONDecoder().decode(Root.self, from: data)
                    
                    let entity = dto.items.map {
                        FeedItemEntity(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
                    }
                    completion(.success(entity))
                } catch {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    
    struct FeedItemDTO: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
    }
    
    let items: [FeedItemDTO]
}
