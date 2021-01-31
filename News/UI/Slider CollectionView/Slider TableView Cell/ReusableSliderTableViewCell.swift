//
//  ReusableSliderTableViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit
import RealmSwift

class ReusableSliderTableViewCell: UITableViewCell {
    
    enum TypeOfCell: Int {
        case articleSlider = 0, buttonSlider
    }
    
    private let dbManager = DBManager()
    private var items: Results<RealmItem>?
    var itemsToken: NotificationToken?
    private var oldRealmItems: Results<RealmItem>? = RealmItem.getAllItems().freeze()
    private let requestDataHandler = RequestDataHandler()
    private var articleBrain = ArticleBrain()
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let arrayOfTitlesForButton = ["Politics", "Sport", "Business", "Army", "Nature", "Art"]
    private var section: TypeOfCell    = .buttonSlider
    
    var tapActionOnSearchButton: ((String) -> ())?
    var showDetailArticleAction: ((DataForArticle) -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        requestDataHandler.getDataForSlider()
        
        //get callback from requestDataHandler
        requestDataHandler.callBack = { [weak self] in
            self?.articleBrain.images = self?.requestDataHandler.dictionaryOfimages ?? [:]
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
                
            case .update(let newItem, _, _, _):
                let indexPath = self?.articleBrain.getIndexToReloadRow(oldRealmArray: self?.oldRealmItems?.freeze(), newRealmArray: newItem, arrayOfNews: self?.requestDataHandler.arrayForSliderOfArticles, section: 0)
                
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
        
        
        collectionView.register(UINib(nibName: Constants.reusableArticleCollectionViewCell, bundle: .main), forCellWithReuseIdentifier: Constants.reusableArticleCollectionViewCell)
        collectionView.register(UINib(nibName: Constants.sliderButtonCollectionView, bundle: .main), forCellWithReuseIdentifier: Constants.sliderButtonCollectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func updateUI(with cell: TypeOfCell) {
        self.section = cell
    }
}

// MARK: UICollectionViewDataSource
extension ReusableSliderTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.section {
        
        case .articleSlider:
            return requestDataHandler.arrayForSliderOfArticles.count 
            
        case .buttonSlider:
            return arrayOfTitlesForButton.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch section {
        
        case .articleSlider:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reusableArticleCollectionViewCell, for: indexPath) as? ReusableArticleCollectionViewCell
            
            let contentForCell = requestDataHandler.arrayForSliderOfArticles[indexPath.row]
            let isSaved = dbManager.isArticleSaved(urlString: contentForCell.urlString)
            
            if let safeImageUrl = contentForCell.urlToImage {
                if let imageData = requestDataHandler.dictionaryOfimages[safeImageUrl] {
                    cell?.previewImage.image = UIImage(data: imageData) ?? #imageLiteral(resourceName: "default")
                }
                
            }
            
            cell?.updateUI(title: contentForCell.title,
                           sourceName: contentForCell.source.name,
                           urlString: contentForCell.urlString,
                           content: contentForCell.content,
                           articleDescription: contentForCell.articleDescription,
                           isSaved: isSaved)
            
            cell?.tapAction = { [weak self] needSave in //catch save action from savebutton of SliderArticle item
                
                if needSave {
                    
                    let imageData = self?.requestDataHandler.dictionaryOfimages[contentForCell.urlToImage ?? ""]
                    let contentForRealm = self?.dbManager.prepareDateForRealm(item: contentForCell,image: imageData)
                    self?.collectionView.updateItemAtRealm(data: contentForRealm,
                                                           needSave: true,
                                                           item: nil)
                    self?.collectionView?.reloadItems(at: [indexPath])
                    
                    
                } else {
                    guard let item = self?.dbManager.getRealmItem(urlString: contentForCell.urlString) else { return }
                    
                    self?.collectionView.updateItemAtRealm(data: nil,
                                                           needSave: false,
                                                           item: item)
                    self?.collectionView?.reloadItems(at: [indexPath])
                }
            }
            return cell ?? UICollectionViewCell()
            
        case .buttonSlider:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.sliderButtonCollectionView, for: indexPath) as? SliderButtonCollectionViewCell
            
            cell?.updateUI(title: arrayOfTitlesForButton[indexPath.row])
            
            cell?.tapAction = { [weak self] button in //catch tap at searchButton slider
                self?.tapActionOnSearchButton?(button)
            }
            return cell ?? UICollectionViewCell()
            
        }
    }
}


// MARK: UICollectionViewDelegate
extension ReusableSliderTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = requestDataHandler.arrayForSliderOfArticles[indexPath.row]
        
        showDetailArticleAction?(articleBrain.getDataForArticleDetail(contentForArticleDetail: content))
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ReusableSliderTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch section {
        case .articleSlider:
            return CGSize(width: 300, height: collectionView.bounds.height)
            
        case .buttonSlider:
            return CGSize(width: 130, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
