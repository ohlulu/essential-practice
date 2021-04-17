//
//  FeedItemMapper.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/11.
//

import Foundation

internal final class FeedItemMapper {
    
    struct Root: Decodable {
        let items: [FeedItemDTO]
        struct FeedItemDTO: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        let entity = root.items.map {
            FeedItemEntity(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
        }
        return .success(entity)
    }
}
