//
//  HTTPClient.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/11.
//

import Foundation

public protocol HTTPClient {
    func send(url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
