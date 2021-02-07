//
//  DBManager.swift
//  News
//
//  Created by Alina Petrovskaya on 25.01.2021.
//

import UIKit
import RealmSwift

class DBManager {
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images.plist")
    
    func prepareDateForRealm(item: Article, image: Data?) -> DataForRealmItem {
        
        let dataForDB: DataForRealmItem = (urlString: item.urlString ?? "",
                                           image: item.urlToImage ?? "",
                                           title: item.title ?? "",
                                           date: item.publishedAt ?? Date(),
                                           sourceName: item.source.name ?? "",
                                           content: item.content ?? "",
                                           articleDescription: item.articleDescription ?? "",
                                           saveButton: true)
        
        if let safeImageURL = item.urlToImage, let safeDataImage = image {
            ImageManager.saveImage(imageURL: safeImageURL, imageData: safeDataImage)
        }
        
        return dataForDB
    }
    
    func getRealmItem(urlString: String?) -> RealmItem? {
        
        if let safeURLString = urlString {
            let myPrimaryKey = safeURLString
            let realm = try! Realm()
            
            let item = realm.object(ofType: RealmItem.self, forPrimaryKey: myPrimaryKey)
            
            return item
        }
        
        return nil
    }
    
    func getImageForBookmarkArticle(imageUrl: String) -> UIImage {
        
        let item = ImageManager.arrayOfImages.first(where: { (imageModel) -> Bool in
            return imageModel.imageURL == imageUrl
         })
        
        if let safeItem = item {
            let image = UIImage(data: safeItem.imageData )
            return image ?? #imageLiteral(resourceName: "default")
        }
        return #imageLiteral(resourceName: "default")
    }
}
