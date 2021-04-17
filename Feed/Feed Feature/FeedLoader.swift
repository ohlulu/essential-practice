//
//  FeedLoader.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/5.
//

import Foundation

public protocol FeedLoader {
    
    typealias Result = Swift.Result<[FeedItemEntity], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
