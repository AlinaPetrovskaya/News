//
//  RequestBuilder.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

protocol RequestBuilder: class {
    init(baseUrl: String)
    
    func buildRequest(with endPoint: NewsServiceEndPoint, _ parameters: [String: String]) -> URLRequest?
}

class ArticlesRequestBuilder: RequestBuilder {
    var url: String
    
    required init(baseUrl: String) {
        self.url = baseUrl
    }
    
    func buildRequest(with endPoint: NewsServiceEndPoint, _ parameters: [String: String]) -> URLRequest? {
        guard var components = URLComponents(string: url + endPoint.toString()) else {
            return nil
        }
        
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let url = components.url else {
            return nil
        }
        
        return URLRequest(url: url)
    }
}
