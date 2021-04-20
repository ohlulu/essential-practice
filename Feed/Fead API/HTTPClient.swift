//
//  HTTPClient.swift
//  Feed
//
//  Created by Ohlulu on 2021/4/11.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func send(url: URL, completion: @escaping (Result) -> Void)
}
