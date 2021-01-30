//
//  DecodeError.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

enum ServerError: Error {
    case unableToDecode
    case unableToCreateRequest
    case unableToGetImageFromUrl
}
