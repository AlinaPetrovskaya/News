//
//  Article.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

struct Article: Codable, Hashable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.urlString == rhs.urlString
    }
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case articleDescription = "description"
        case urlString = "url"
        case urlToImage
        case publishedAt
        case content
    }
    
    let source: Source
    let author: String?
    let title: String?
    let articleDescription: String?
    let urlString: String?
    let urlToImage: String?
    let publishedAt: Date?
    let content: String?
}

// MARK: - Source
struct Source: Codable, Hashable  {
    let name: String?
}
