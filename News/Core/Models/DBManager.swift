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
    lazy var realm = try! Realm()
    
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
            saveImage(imageURL: safeImageURL, imageData: safeDataImage)
        }
        
        return dataForDB
    }
    
    func getRealmItem(urlString: String?) -> RealmItem? {
        
        if let safeURLString = urlString {
            let myPrimaryKey = safeURLString
            
            
            let item = realm.object(ofType: RealmItem.self, forPrimaryKey: myPrimaryKey)
            
            return item
        }
        
        return nil
    }
    
    func isArticleSaved(urlString: String?) -> Bool {
        
        if let safeURLString = urlString {
            
            let myPrimaryKey = safeURLString
            let item = realm.object(ofType: RealmItem.self, forPrimaryKey: myPrimaryKey)
            
            guard item != nil else { return false }
            return true
        }
        
        return false
    }
    
    func getImageForBookmarkArticle(imageUrl: String) -> UIImage {
        
        let item = DataImageList.arrayOfImages.first(where: { (imageModel) -> Bool in
            return imageModel.imageURL == imageUrl
         })
        
        if let safeItem = item {
            let image = UIImage(data: safeItem.imageData )
            return image ?? #imageLiteral(resourceName: "default")
        }
        return #imageLiteral(resourceName: "default")
    }
    
    
    func deleteImageFromFileManager(imageURL: String?) {
        guard let safeURL = imageURL else { return }
        
       let index = DataImageList.arrayOfImages.firstIndex { (imageModel) -> Bool in
            return imageModel.imageURL == safeURL
        }
        
        if let safeIndex = index {
            DataImageList.arrayOfImages.remove(at: safeIndex)
            saveImageIntoFileManager()
        }
    }
    
    
    private func saveImage(imageURL: String, imageData: Data) {
        
        let uniquenessChecker =  DataImageList.arrayOfImages.contains(where: { (imageModel) -> Bool in
            return imageModel.imageURL == imageURL
        })
        
        if uniquenessChecker {
            return
        }
        
        DataImageList.arrayOfImages.append(ImageManagerModel(imageURL: imageURL, imageData: imageData))
        
        saveImageIntoFileManager()
    }
    
    
    private func saveImageIntoFileManager() {
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images.plist")
        
        guard let dataFile = dataFilePath else { return }
        
        let encoder  = PropertyListEncoder()
        do {
            let data = try encoder.encode(DataImageList.arrayOfImages)
            try data.write(to: dataFile)
            
        } catch {
            print("Can't save data into FileManager")
        }
    }
}
