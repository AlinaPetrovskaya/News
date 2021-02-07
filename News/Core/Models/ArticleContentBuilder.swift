//
//  CellBuilder.swift
//  News
//
//  Created by Alina Petrovskaya on 20.01.2021.
//

import UIKit
import RealmSwift


class ArticleContentBuilder {
    
    var images: [String : Data] = [:]
    
    
    func buildCellForArticleTable(cell: ArticleTableViewCell?, contentForCell: Article?) -> ArticleTableViewCell {
        
        let dataForCell = prepareDateForCell(with: contentForCell)
        cell?.updateUI(content: dataForCell)
        
        return cell ?? ArticleTableViewCell()
    }
    
    func buildCellForSlider(cell: SliderArticleCollectionViewCell?, contentForCell: Article?) -> SliderArticleCollectionViewCell {
  
        let dataForCell = prepareDateForCell(with: contentForCell)
        cell?.updateUI(content: dataForCell)
        
        return cell ?? SliderArticleCollectionViewCell()
    }
    
    private func prepareDateForCell(with contentForCell: Article?) -> DataForCell {
        
        let isSaved = isArticleSaved(urlString: contentForCell?.urlString)

        let dateString = contentForCell?.publishedAt?.convertDateIntoString(type: .dateForPreviewNews)
        
        var dataConstructor = (image: #imageLiteral(resourceName: "default"),
                               title: contentForCell?.title,
                               date: dateString,
                               sourceName: contentForCell?.source.name,
                               urlString: contentForCell?.urlString,
                               content: contentForCell?.content,
                               articleDescription: contentForCell?.articleDescription,
                               isSaved: isSaved)
       
        if let imageURL = contentForCell?.urlToImage { //set image for cell
            if let imageData = images[imageURL] {
                let image = UIImage(data: imageData)
                dataConstructor.image = image ?? #imageLiteral(resourceName: "default")
                
                return  dataConstructor
            }
        }
        return dataConstructor
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
        var dataForDetailVC: DataForArticle = (
            image: #imageLiteral(resourceName: "default"),
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
    
    private func isArticleSaved(urlString: String?) -> Bool {
        
        if let safeURLString = urlString {
            
            let myPrimaryKey = safeURLString
            let realm = try! Realm()
            
            let item = realm.object(ofType: RealmItem.self, forPrimaryKey: myPrimaryKey)
            
            guard item != nil else { return false }
            return true
        }
        
        return false
    }
}
