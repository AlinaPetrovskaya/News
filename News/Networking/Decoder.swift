//
//  Decoder.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

protocol Decoder {
    associatedtype ReturnType: Codable
    func decode(from data: Data?) -> ReturnType?
    func setDateFormat(_ dateFormat: String)
}

class DefaultDecoder<T: Codable>: Decoder {
    typealias ReturnType = T
    
    let decoder: JSONDecoder
    let dateFormatter: DateFormatter
    
    init(decoder: JSONDecoder = JSONDecoder(), dateFormatter: DateFormatter = DateFormatter(), localeIdentifier: String, dateFormat: String) {
        self.decoder                      = decoder
        self.dateFormatter                = dateFormatter
        self.dateFormatter.locale         = Locale(identifier: localeIdentifier)
        self.dateFormatter.dateFormat     = dateFormat
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func setDateFormat(_ dateFormat: String) {
        dateFormatter.dateFormat     = dateFormat
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func decode(from data: Data?) -> ReturnType? {
        guard let data = data else {
            return nil
        }
        
        let result = try? decoder.decode(T.self, from: data)
        
        return result
    }
}
