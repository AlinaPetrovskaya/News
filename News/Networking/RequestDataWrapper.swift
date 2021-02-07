//
//  ArticleBrain.swift
//  News
//
//  Created by Alina Petrovskaya on 08.01.2021.
//

import UIKit

class RequestDataWrapper {
    
    var callBack: (() -> ())?
    var presentErrorAlert: ((Error) -> ())?
    
    private let newsService = NewsNetworkingService(apiKey: "d64358ad9c27440184ba2b6ed206381f")
    
    var arrayForListOfArticles: [Article] = [] {
        didSet {
            saveImagesIntoDictionary(arrayForListOfArticles)
        }
    }
    private(set) var arrayForSliderOfArticles: [Article] = [] {
        didSet {
            saveImagesIntoDictionary(arrayForSliderOfArticles)
        }
    }
    
    private(set) var dictionaryOfimages: [String: Data] = [:] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.callBack?()
            }
        }
    }

    
    func getDataForSlider() {
        newsService.requestData(for: .topHeadliners) { [weak self] (result) in
            if let safeSelf = self {
                safeSelf.saveContentDataIntoArray(data: result,
                                           arrayOfNews: &safeSelf.arrayForSliderOfArticles)
            }
        }
    }
    
    
    func getDataForListNews(for typeArticle: String) {
        newsService.requestData(for: .some(typeArticle),
                                dateFrom: Date(timeIntervalSinceNow: -300000),
                                dateTo: Date()) { [weak self] (result) in
            
                self?.saveContentDataIntoArray(data: result,
                                               arrayOfNews: &self!.arrayForListOfArticles)
            }
        }
    
    func getDataFromFilter(for searchWord: String?,
                           dateFrom: Date,
                           dateTo: Date) {
        
        if searchWord == nil || searchWord == "" || searchWord == " " {
            newsService.requestData(for: .topHeadliners,
                                    dateFrom: dateFrom,
                                    dateTo: dateTo) { [weak self] (result) in
                
                if let safeSelf = self {
                    safeSelf.saveContentDataIntoArray(data: result,
                                               arrayOfNews: &safeSelf.arrayForListOfArticles)
                }
            }
            
        } else {
            if let safeSearchWord = searchWord {
                newsService.requestData(for: .some(safeSearchWord),
                                        dateFrom: dateFrom,
                                        dateTo: dateTo) { [weak self] (result) in
                    
                    if let safeSelf = self {
                        safeSelf.saveContentDataIntoArray(data: result,
                                                   arrayOfNews: &safeSelf.arrayForListOfArticles)
                    }
                }
            }
        }
    }
    
    private func saveContentDataIntoArray(data: Result<[Article], Error>,
                                   arrayOfNews: inout [Article]) {
        
        switch data {
        
        case .success(var articleArray):
            articleArray = Array(Set(articleArray)) // make unic items
            
            let sortedArray = articleArray.sorted(by: { firstItem, secondItem in
                
                guard let first  = firstItem.publishedAt,
                      let second = secondItem.publishedAt
                else { return false }
                
                return first > second
            })
            
            arrayOfNews = sortedArray
            
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.presentErrorAlert?(error)
            }
        }
    }
    
    private func saveImagesIntoDictionary(_ array: [Article]) {
        var dictionary: [String: Data] = [:]
        let downloadGroup = DispatchGroup()
        
        dictionaryOfimages.forEach { (url, image) in
            dictionary[url] = image
        }
        
        
        array.forEach { [weak self] (item) in
            guard let safeURL = item.urlToImage  else { return }
            
            if !safeURL.contains("http://") {
                downloadGroup.enter()
                self?.newsService.getImage(imageURL: safeURL, completion: { (imageData) in
                    
                    if let safeData = imageData {
                        
                        dictionary[safeURL] = safeData
                        downloadGroup.leave()
                    }
                })
            }
        }
        downloadGroup.wait()
        DispatchQueue.main.async { [weak self] in
            self?.dictionaryOfimages = dictionary
        }
    }
    
//    private func errorAlertShow(error: Error) {
//
//        let alert = UIAlertController(title: "Error", message: error.localizedDescription , preferredStyle: .alert)
//
//        let dismissAction = UIAlertAction(title: "Close", style: .cancel) { _ in
//            return
//        }
//        alert.addAction(dismissAction)
//
//        let root = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
//        root?.present(alert, animated: true, completion: nil)
//    }
}
