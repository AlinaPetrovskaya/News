//
//  DataImageList.swift
//  News
//
//  Created by Alina Petrovskaya on 27.01.2021.
//

import Foundation

class ImageManager {
    static var arrayOfImages: [ImageManagerModel] = []
    
    static func loadImageItems() {
         let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images.plist")
         
         guard let dataFile = dataFilePath else { return }

         if let data = try? Data(contentsOf: dataFile) {

             let decoder = PropertyListDecoder()
         do {
               let imageData = try decoder.decode([ImageManagerModel].self, from: data)
             ImageManager.arrayOfImages = imageData
             } catch {
                 print("Error at reading data: \(error.localizedDescription)")
             }
         }}
    
   static func deleteImageFromFileManager(imageURL: String?) {
        guard let safeURL = imageURL else { return }
        
       let index = ImageManager.arrayOfImages.firstIndex { (imageModel) -> Bool in
            return imageModel.imageURL == safeURL
        }
        
        if let safeIndex = index {
            ImageManager.arrayOfImages.remove(at: safeIndex)
            saveImageIntoFileManager()
        }
    }
    
    
    static func saveImage(imageURL: String, imageData: Data) {
        
        let uniquenessChecker =  ImageManager.arrayOfImages.contains(where: { (imageModel) -> Bool in
            return imageModel.imageURL == imageURL
        })
        
        if uniquenessChecker {
            return
        }
        
        ImageManager.arrayOfImages.append(ImageManagerModel(imageURL: imageURL, imageData: imageData))
        
        saveImageIntoFileManager()
    }
    
    
    static private func saveImageIntoFileManager() {
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Images.plist")
        
        guard let dataFile = dataFilePath else { return }
        
        let encoder  = PropertyListEncoder()
        do {
            let data = try encoder.encode(ImageManager.arrayOfImages)
            try data.write(to: dataFile)
            
        } catch {
            print("Can't save data into FileManager")
        }
    }
}
