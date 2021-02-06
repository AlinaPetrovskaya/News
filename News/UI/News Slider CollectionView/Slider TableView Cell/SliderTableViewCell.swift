//
//  ReusableSliderTableViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit
import RealmSwift

class SliderTableViewCell: UITableViewCell {
    
    enum TypeOfCell: Int {
        case articleSlider = 0, buttonSlider
    }
    
    private let dbManager = DBManager()
    private var items: Results<RealmItem>?
    var itemsToken: NotificationToken?
    private var oldRealmItems: Results<RealmItem>? = RealmItem.getAllItems().freeze()
    private let requestDataHandler = RequestDataWrapper()
    private var articleBrain = ArticleContentBuilder()
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var showDetailArticleAction: ((DataForArticle) -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        requestDataHandler.getDataForSlider()
        
        //get callback from requestDataHandler
        requestDataHandler.callBack = { [weak self] in
            self?.articleBrain.images = self?.requestDataHandler.dictionaryOfimages ?? [:]
            self?.loaderIndicator.stopAnimating()
            self?.collectionView.reloadData()
        }
        
        updateDataFromRealm()
        prepareUI()
    }
    
    
    private func updateDataFromRealm() {
        items = RealmItem.getAllItems()
        
        itemsToken = items?.observe({ [weak collectionView, weak self] changes in //let Realm to know that u want to recive updates
            
            switch changes {
            
            case .initial:
                collectionView?.reloadData()
                self?.oldRealmItems = RealmItem.getAllItems().freeze()
                
            case .update(let newItem, _, _, _):
                let indexPath = self?.articleBrain.getIndexToReloadRow(
                    oldRealmArray: self?.oldRealmItems?.freeze(),
                    newRealmArray: newItem,
                    arrayOfNews: self?.requestDataHandler.arrayForSliderOfArticles,
                    section: 0)
                
                if let safeIndexPath = indexPath {
                    collectionView?.reloadItems(at: [safeIndexPath])
                }
                
                self?.oldRealmItems = newItem.freeze()
                
            case .error:
                break
            }
        })
    }
    
    private func prepareUI() {
        
        
        collectionView.register(UINib(nibName: Constants.sliderArticleCollectionViewCell, bundle: .main), forCellWithReuseIdentifier: Constants.sliderArticleCollectionViewCell)
        collectionView.register(UINib(nibName: Constants.sliderButtonCollectionView, bundle: .main), forCellWithReuseIdentifier: Constants.sliderButtonCollectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: UICollectionViewDataSource
extension SliderTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requestDataHandler.arrayForSliderOfArticles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.sliderArticleCollectionViewCell, for: indexPath) as? SliderArticleCollectionViewCell
        
        let contentForCell = requestDataHandler.arrayForSliderOfArticles[indexPath.row]
        
        let newCell = articleBrain.buildCellForSlider(cell: cell, contentForCell: contentForCell)
        
        newCell.tapAction = { [weak self] needSave in //catch save action from savebutton of SliderArticle item
            if needSave {
                let imageData = self?.requestDataHandler.dictionaryOfimages[contentForCell.urlToImage ?? ""]
                let contentForRealm = self?.dbManager.prepareDateForRealm(item: contentForCell, image: imageData)
                
                self?.collectionView.updateItemAtRealm(
                    data: contentForRealm,
                    needSave: true,
                    item: nil)
                
            } else {
                guard let item = self?.dbManager.getRealmItem(urlString: contentForCell.urlString) else { return }
                ImageManager.deleteImageFromFileManager(imageURL: item.imageURL)
                self?.collectionView.updateItemAtRealm(data: nil,
                                                       needSave: false,
                                                       item: item)
            }
        }
        return newCell
    }
}


// MARK: UICollectionViewDelegate
extension SliderTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = requestDataHandler.arrayForSliderOfArticles[indexPath.row]
        showDetailArticleAction?(articleBrain.getDataForArticleDetail(contentForArticleDetail: content))
    }
}


// MARK: UICollectionViewDelegateFlowLayout
extension SliderTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 300, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
