//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/7.
//

import Foundation
public protocol HTTPClient {
    func send(url: URL)
}

public class RemoteFeedLoader {
    
    private var client: HTTPClient
    private var url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.send(url: url)
    }
}

