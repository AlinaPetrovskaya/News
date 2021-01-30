//
//  NewsNetworkingService.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import Foundation

class NewsNetworkingService {
    
    private struct Constants {
        static let deafaultCountryCode     = "us"
        static let baseUrlString           = "https://newsapi.org/v2/"
        static let defaultLocaleIdentifier = "en_US_POSIX"
        static let defaultDateFormat       = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    private let apiKey: String
    private let countryCode: String
    private let requestBuilder: RequestBuilder
    
    init(apiKey: String, countryCode: String = Constants.deafaultCountryCode, requestBuilder: RequestBuilder = ArticlesRequestBuilder(baseUrl: Constants.baseUrlString)) {
        self.apiKey = apiKey
        self.countryCode = countryCode
        self.requestBuilder = requestBuilder
    }
    
    func getImage(imageURL: String?, completion: @escaping (Data?) -> ()) {
        
        guard let safeImageURL = imageURL else { return }
        
        if let url = URL(string: safeImageURL) {
            
            let session = URLSession(configuration: .default)
            let task    = session.dataTask(with: url) { (data, _, _) in
                DispatchQueue.main.async {
                    completion(data)
                }
            }
            task.resume()
        }
    }
    
    func requestData(for endPoint: NewsServiceEndPoint, dateFrom: Date? = nil, dateTo: Date? = nil, completion: @escaping (Result<[Article], Error>) -> ()) {
        
        let session = URLSession.shared
        let params  = convertToParameters(endPoint, dateFrom: dateFrom, dateTo: dateTo)
        
        guard let requset = requestBuilder.buildRequest(with: endPoint, params) else {
            completion(.failure(ServerError.unableToCreateRequest))
            return
        }
        
        let task = session.dataTask(with: requset, completionHandler: { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            let decoder = DefaultDecoder<ApiResponse>(localeIdentifier: Constants.defaultLocaleIdentifier, dateFormat: Constants.defaultDateFormat)

            let response = decoder.decode(from: data)
            if let articles = response?.articles {
                completion(.success(articles))
            } else {
                completion(.failure(ServerError.unableToDecode))
            }
            
        })
        task.resume()
    }
    
    private func convertToParameters(_ endPoint: NewsServiceEndPoint, dateFrom: Date? = nil, dateTo: Date? = nil) -> [String: String] {
        
        var params: [String: String] = ["apiKey" : apiKey]
        switch endPoint {
        case .some(let value):
            params["q"] = value
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            if let dateFrom = dateFrom, let dateTo = dateTo {
                params["from"] = dateFormatter.string(from: dateFrom)
                params["to"]   = dateFormatter.string(from: dateTo)
            }
        default:
            params["country"] = Constants.deafaultCountryCode
        }
        
        return  params
    }
}
