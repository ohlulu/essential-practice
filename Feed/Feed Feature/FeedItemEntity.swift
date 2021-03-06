//
//  FeedItemEntity.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/5.
//

import Foundation

public struct FeedItemEntity: Decodable, Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
