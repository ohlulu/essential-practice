//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/7.
//

import Foundation
public protocol HTTPClient {
    func send(url: URL, completion: (Error) -> Void)
}

public class RemoteFeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    private var client: HTTPClient
    private var url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: (Error) -> Void) {
        client.send(url: url) { error in
            completion(.connectivity)
        }
    }
}

