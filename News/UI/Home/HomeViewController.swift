//
//  ViewController.swift
//  News
//
//  Created by Alina Petrovskaya on 22.12.2020.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    enum TypeOfCell: Int {
        case articleSlider = 0, articleList
    }
    
    private let requestDataHandler    = RequestDataWrapper()
    private var articleContentBuilder = ArticleContentBuilder()
    private let dbManager             = DBManager()
    
    private var items: Results<RealmItem>?
    private var oldRealmItems: Results<RealmItem>? = RealmItem.getAllItems().freeze()
    private var itemsToken: NotificationToken?
    private var dataForDetailVC: DataForArticle?
    private var currentcell: (Int, Int)?
    
    @IBOutlet weak var articleTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        items = RealmItem.getAllItems()
        
        itemsToken = items?.observe({ [weak articleTable, weak self] changes in //let Realm to knoe that u want to recive updates
          
          switch changes {
          
          case .initial:
            articleTable?.reloadData()
            self?.oldRealmItems = RealmItem.getAllItems().freeze()
           
          case .update(let newItem, _, _, _):
            let indexPath = self?.articleContentBuilder.getIndexToReloadRow(
                oldRealmArray: self?.oldRealmItems?.freeze(),
                newRealmArray: newItem,
                arrayOfNews: self?.requestDataHandler.arrayForListOfArticles,
                section: 1)
            
            if let safeIndexPath = indexPath {
                articleTable?.reloadRows(at: [safeIndexPath], with: .automatic)
            }
            self?.oldRealmItems = newItem.freeze()
            
          case .error:
            break
          }
        })
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      
      itemsToken?.invalidate()

    }
    
    private func prepareTableView() {
        articleTable.delegate   = self
        articleTable.dataSource = self
        
        //make server requests
        requestDataHandler.getDataForListNews(for: "politics")
        
        //get callback from requestDataHandler
        requestDataHandler.callBack = { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.articleContentBuilder.images = self?.requestDataHandler.dictionaryOfimages ?? [:]
            self?.articleTable.reloadData()
        }
        
        
        //register reusable cells
        articleTable.register(UINib(nibName: Constants.sliderTableViewCell, bundle: .main), forCellReuseIdentifier: Constants.sliderTableViewCell)
        articleTable.register(UINib(nibName: Constants.articleTableViewCell, bundle: .main), forCellReuseIdentifier: Constants.articleTableViewCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.fromHomeToAtricle {
            
            weak var vc = segue.destination as? ArticleDetailController
            vc?.dataForDetailArticle = dataForDetailVC
        }
    }
}

// MARK: UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if requestDataHandler.arrayForListOfArticles.count == 0 {
            return 0
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch TypeOfCell(rawValue: section) {
            
            case .articleSlider:
                return 1
            case .articleList:
                return requestDataHandler.arrayForListOfArticles.count
            default:
                return 0
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch TypeOfCell(rawValue: indexPath.section) {
        
        case .articleSlider:
            let sliderTableViewCell = articleTable.dequeueReusableCell(withIdentifier: Constants.sliderTableViewCell) as? SliderTableViewCell
            
            //catch showDetailArticle action from slider
            sliderTableViewCell?.showDetailArticleAction = { [weak self] content in
                
                self?.dataForDetailVC = content
                DispatchQueue.main.async { [weak self] in
                    self?.performSegue(withIdentifier: Constants.fromHomeToAtricle, sender: self)
                }
            }
            
            return sliderTableViewCell ?? UITableViewCell()
            
        case .articleList:
            
            let cell = articleTable.dequeueReusableCell(withIdentifier: Constants.articleTableViewCell) as? ArticleTableViewCell
            
            let contentForCell  = requestDataHandler.arrayForListOfArticles[indexPath.row]
            
            let newCell = articleContentBuilder.buildCellForArticleTable(cell: cell, contentForCell: contentForCell)
            
            //catch action from cell
            newCell.tapAction = { [weak self] needSave in
                self?.currentcell = (indexPath.row, indexPath.section)
                
                if needSave {
                    let imageData = self?.requestDataHandler.dictionaryOfimages[contentForCell.urlToImage ?? ""]
                    
                    let contentForRealm = self?.dbManager.prepareDateForRealm(item: contentForCell, image: imageData)
                    
                    self?.articleTable.updateItemAtRealm(data: contentForRealm, needSave: true, item: nil)
                    
                } else {
                    guard let item = self?.dbManager.getRealmItem(urlString: contentForCell.urlString) else { return }
                    
                    ImageManager.deleteImageFromFileManager(imageURL: item.imageURL)
                    
                    self?.articleTable.updateItemAtRealm(data: nil, needSave: false, item: item)
                }
            }
            return newCell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch  TypeOfCell(rawValue: indexPath.section){
        case .articleList:
            let contentForArticleDetail  = requestDataHandler.arrayForListOfArticles[indexPath.row]
            
            dataForDetailVC = articleContentBuilder.getDataForArticleDetail(contentForArticleDetail: contentForArticleDetail)
            
            performSegue(withIdentifier: Constants.fromHomeToAtricle, sender: self)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 252 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 130
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch TypeOfCell(rawValue: section) {
        case .articleSlider:
            let view = HeaderView(
                for: .headerForSliderNews,
                labelText: "Today's read")
            
            return view
            
        default:
            let view = HeaderView(
                for: .headerForHomeListNews,
                labelText: "For you")
            
            view.tapActionOnSearchButton = { [weak self] buttonText in
                
                self?.requestDataHandler.getDataForListNews(for: buttonText)
                
            }
            return view
        }
    }
}
