//
//  FeedItem.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/5.
//

import Foundation

public struct FeedItem: Decodable, Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
