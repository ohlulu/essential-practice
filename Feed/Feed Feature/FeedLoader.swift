//
//  FeedLoader.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/5.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
