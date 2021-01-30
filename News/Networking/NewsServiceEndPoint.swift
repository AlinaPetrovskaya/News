//
//  NewsServiceEndPoint.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

enum NewsServiceEndPoint {
    case topHeadliners
    case some(String)
    
    func toString() -> String {
        switch self {
        case .topHeadliners:
            return "top-headlines"
        case .some:
            return "everything"
        }
    }
}
