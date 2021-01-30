//
//  ApiResponse.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

struct ApiResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case status
        case articles
        case totalResults
    }
    
    let status: String
    let totalResults: Int?
    let articles: [Article]
}
