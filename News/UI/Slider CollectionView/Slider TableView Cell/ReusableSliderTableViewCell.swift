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
    private var reloadItem: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var dictionaryOfImages: [String: Data]?
    private var selectedItem: IndexPath?
    private let arrayOfTitlesForButton = ["Politics", "Sport", "Business", "Army", "Nature", "Art"]
    private var section: TypeOfCell    = .buttonSlider
    
    private var arrayOfNews: [Article]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var tapActionOnSearchButton: ((String) -> ())?
    var reloadTableViewCell: (() -> (Bool))?
    var showDetailArticleAction: (((image: UIImage?,
                                title: String?,
                                sourceName: String?,
                                urlString: String?,
                                content: String?,
                                articleDescription: String?)) -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        items = RealmItem.getAllItems()
        prepareUI()
    }
    
    private func prepareUI() {
        
        
        collectionView.register(UINib(nibName: Constants.reusableArticleCollectionViewCell, bundle: .main), forCellWithReuseIdentifier: Constants.reusableArticleCollectionViewCell)
        collectionView.register(UINib(nibName: Constants.sliderButtonCollectionView, bundle: .main), forCellWithReuseIdentifier: Constants.sliderButtonCollectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func updateUI(with cell: TypeOfCell, arrayOfNews: [Article]?, dictionaryOfImages: [String: Data]?) {
        
        if let news = arrayOfNews, let images = dictionaryOfImages {
            self.dictionaryOfImages = images
            self.arrayOfNews        = news
        }
        
        self.section = cell
        
    }
}

// MARK: UICollectionViewDataSource
extension ReusableSliderTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.section {
        
        case .articleSlider:
            return arrayOfNews?.count ?? 0
            
        case .buttonSlider:
            return arrayOfTitlesForButton.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch section {
        
        case .articleSlider:
           
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reusableArticleCollectionViewCell, for: indexPath) as? ReusableArticleCollectionViewCell
            
            let contentForCell = arrayOfNews?[indexPath.row]
            let isSaved = dbManager.isArticleSaved(urlString: contentForCell?.urlString)
            
            if let safeImageUrl = contentForCell?.urlToImage {
                if let imageData = dictionaryOfImages?[safeImageUrl] {
                    cell?.previewImage.image = UIImage(data: imageData) ?? #imageLiteral(resourceName: "default")
                }
                
            }
            cell?.updateUI(title: contentForCell?.title,
                           sourceName: contentForCell?.source.name,
                           urlString: contentForCell?.urlString,
                           content: contentForCell?.content,
                           articleDescription: contentForCell?.articleDescription,
                           isSaved: isSaved)
            
           
            
            cell?.tapAction = { [weak self] needSave in //catch save action from savebutton of SliderArticle item
                
                if needSave {
                    guard let articleContent = contentForCell else { return }
                    let imageData = self?.dictionaryOfImages?[contentForCell?.urlToImage ?? ""]

                    let contentForRealm = self?.dbManager.prepareDateForRealm(item: articleContent, image: imageData)
                    
                    self?.collectionView.updateItemAtRealm(data: contentForRealm,
                                                           needSave: true,
                                                           item: nil)
                   
                   // self?.collectionView.reloadItems(at: [indexPath])
                                        
                    
                } else {
                    guard let item = self?.dbManager.getRealmItem(urlString: contentForCell?.urlString) else { return }
                    
                    self?.collectionView.updateItemAtRealm(data: nil,
                                                           needSave: false,
                                                           item: item)
                   
                       // self?.collectionView.reloadItems(at: [indexPath])
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
        if let content = arrayOfNews?[indexPath.row] {
            var image  = #imageLiteral(resourceName: "default")
            
            if let urlToImage = content.urlToImage {
                if let imageData = dictionaryOfImages?[urlToImage] {
                    image = UIImage(data: imageData) ?? #imageLiteral(resourceName: "default")
                }
            }

            showDetailArticleAction?((image: image,
                                 title: content.title,
                                 sourceName: content.source.name,
                                 urlString: content.urlString,
                                 content: content.content,
                                 articleDescription: content.articleDescription))
        }
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
