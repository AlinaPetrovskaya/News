//
//  CellBuilder.swift
//  News
//
//  Created by Alina Petrovskaya on 20.01.2021.
//

import UIKit
import RealmSwift


class ArticleBrain {
    
    enum TypeForGetDate {
        case dateForPreviewNews
        case dateForFilterButton
    }
    
    var images: [String : Data] = [:]
    var dbManager = DBManager()
    
    func buildCellForArticleTable(cell: ReusableArticleTableViewCell?, contentForCell: Article?) -> ReusableArticleTableViewCell {
        
        let dateString = convertDateIntoString(date: contentForCell?.publishedAt, type: .dateForPreviewNews)
        
        if let imageURL = contentForCell?.urlToImage { //set image for cell
            if let imageData = images[imageURL] {
                let image = UIImage(data: imageData)
                cell?.previewImage.image = image ?? #imageLiteral(resourceName: "default")
            }
        }
        
        let isSaved = dbManager.isArticleSaved(urlString: contentForCell?.urlString)
        cell?.updateUI(title: contentForCell?.title,
                       date: dateString,
                       sourceName: contentForCell?.source.name,
                       urlString: contentForCell?.urlString,
                       content: contentForCell?.content,
                       articleDescription: contentForCell?.articleDescription,
                       isSaved: isSaved)
        
        return cell ?? ReusableArticleTableViewCell()
    }
    
    func buildCellForSlider(cell: ReusableArticleCollectionViewCell?, contentForCell: Article?) -> ReusableArticleCollectionViewCell {
        let isSaved = dbManager.isArticleSaved(urlString: contentForCell?.urlString)

        var dataConstructor = (image: #imageLiteral(resourceName: "default"),
                               title: contentForCell?.title,
                               sourceName: contentForCell?.source.name,
                               urlString: contentForCell?.urlString,
                               content: contentForCell?.content,
                               articleDescription: contentForCell?.articleDescription,
                               isSaved: isSaved)
       
        if let imageURL = contentForCell?.urlToImage { //set image for cell
            if let imageData = images[imageURL] {
                let image = UIImage(data: imageData)
                dataConstructor.image = image ?? #imageLiteral(resourceName: "default")
                cell?.updateUI(content: dataConstructor)
                
                return  cell ?? ReusableArticleCollectionViewCell()
            }
        }
        
        
        cell?.updateUI(content: dataConstructor)
        
        return cell ?? ReusableArticleCollectionViewCell()
    }
    
    func getIndexToReloadRow(oldRealmArray: Results<RealmItem>?, newRealmArray: Results<RealmItem>, arrayOfNews: [Article]?, section: Int) -> IndexPath? {
        
        var oldURLS = Set<String>()
        var newURLS = Set<String>()
        
        oldRealmArray?.forEach({ (item) in
            oldURLS.insert(item.urlString)
        })
        
        newRealmArray.forEach({ (item) in
            newURLS.insert(item.urlString)
        })
        
        let differentURL = oldURLS.symmetricDifference(newURLS)
        
        if differentURL.isEmpty {
            return nil
        }
        
        let indexForReload = arrayOfNews?.firstIndex(where: { (article) -> Bool in
            return article.urlString == differentURL.first
        })
        
        guard let row = indexForReload else { return nil }
        
        let indexPath = IndexPath(row: row, section: section)
        
        return indexPath
    }
    
 
    
    func getDataForArticleDetail(contentForArticleDetail: Article) -> DataForArticle {
        
        var dataForDetailVC: DataForArticle  = (image: #imageLiteral(resourceName: "default"),
                                                title: contentForArticleDetail.title,
                                                sourceName: contentForArticleDetail.source.name,
                                                urlString: contentForArticleDetail.urlString,
                                                content: contentForArticleDetail.content,
                                                articleDescription: contentForArticleDetail.articleDescription)
        
        guard let image = contentForArticleDetail.urlToImage else {
            return dataForDetailVC
        }
        
        if let imageData = images[image] {
            dataForDetailVC.image =  UIImage(data: imageData) ?? #imageLiteral(resourceName: "default")
        }
        
        return dataForDetailVC
    }
    
    
    func getPreviousDate() -> Date {
        let dateFormatter = DateFormatter()
        var dayComponent  = DateComponents()
        
        dayComponent.day         = -1
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            return previousDay
        }
        
        return Date()
    }
    
    
    func convertDateIntoString(date: Date?, type: TypeForGetDate) -> String {
        guard let safeDate = date else { return "no Date" }
        
        let dateFormatter  = DateFormatter()
        
        switch type {
        case .dateForPreviewNews:
            dateFormatter.dateFormat = "MMM d, yyyy • HH:mm"
            return dateFormatter.string(from: safeDate)
            
        case .dateForFilterButton:
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: safeDate)
        }
    }
    
}
