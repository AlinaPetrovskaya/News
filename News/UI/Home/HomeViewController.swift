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
    
    private let requestDataHandler = RequestDataHandler()
    private var articleBrain       = ArticleBrain()
    private let dbManager          = DBManager()
    
    private var items: Results<RealmItem>?
    private var itemsToken: NotificationToken?
    private var dataForDetailVC: DataForArticle?
    private var currentcell: (Int, Int)?
    
    @IBOutlet weak var articleTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemsToken = items?.observe({ [weak articleTable, weak self] changes in //let Realm to knoe that u want to recive updates
          
          switch changes {
          
          case .initial:
            articleTable?.reloadData()
           
          case .update(_, _, _, _):
            break
                
          case .error:
            break
          }
        })
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = RealmItem.getAllItems()
        
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
        requestDataHandler.getDataForSlider()
        
        //get callback from requestDataHandler
        requestDataHandler.callBack = { [weak self] in
            self?.activityIndicator.alpha = 0
            self?.articleBrain.images = self?.requestDataHandler.dictionaryOfimages ?? [:]
            self?.articleTable.reloadData()
        }
        
        
        //register reusable cells
        articleTable.register(UINib(nibName: Constants.reusableSliderTableViewCell, bundle: .main), forCellReuseIdentifier: Constants.reusableSliderTableViewCell)
        articleTable.register(UINib(nibName: Constants.reusableArticleCell, bundle: .main), forCellReuseIdentifier: Constants.reusableArticleCell)
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
            let sliderTableViewCell = articleTable.dequeueReusableCell(withIdentifier: Constants.reusableSliderTableViewCell) as? ReusableSliderTableViewCell
            
            sliderTableViewCell?.updateUI(with: .articleSlider, arrayOfNews: requestDataHandler.arrayForSliderOfArticles, dictionaryOfImages: requestDataHandler.dictionaryOfimages)
            
            //catch showDetailArticle action from slider
            sliderTableViewCell?.showDetailArticleAction = { [weak self] content in
                
                self?.dataForDetailVC = content
                DispatchQueue.main.async { [weak self] in
                    self?.performSegue(withIdentifier: Constants.fromHomeToAtricle, sender: self)
                }
            }
            
            return sliderTableViewCell ?? UITableViewCell()
            
        case .articleList:
            
            let cell = articleTable.dequeueReusableCell(withIdentifier: Constants.reusableArticleCell) as? ReusableArticleTableViewCell
            
            let contentForCell  = requestDataHandler.arrayForListOfArticles[indexPath.row]
            
            let newCell = articleBrain.buildCellForArticleTable(cell: cell, contentForCell: contentForCell)
            
            //catch action from cell
            newCell.tapAction = { [weak self] needSave in
                self?.currentcell = (indexPath.row, indexPath.section)
                
                let imageData = self?.requestDataHandler.dictionaryOfimages[contentForCell.urlToImage ?? ""]
                let contentForRealm = self?.dbManager.prepareDateForRealm(item: contentForCell, image: imageData)
                
                if needSave {
                    self?.articleTable.updateItemAtRealm(data: contentForRealm, needSave: true, item: nil)
                    
                } else {
                    guard let item = self?.dbManager.getRealmItem(urlString: contentForCell.urlString) else { return }
                    self?.dbManager.deleteImageFromFileManager(imageURL: item.imageURL)
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
            
            dataForDetailVC = articleBrain.getDataForArticleDetail(contentForArticleDetail: contentForArticleDetail)
            
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
        let label = UILabel(frame: CGRect(x: 24, y: 0, width: tableView.frame.width, height: 50))
        label.font = UIFont(name: "PlayfairDisplay-Medium", size: 24)
        
        switch TypeOfCell(rawValue: section) {
        
        case .articleSlider:
            let view = UIView(frame: CGRect(x: 24, y: 0, width: tableView.frame.width, height: 50))
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            view.addSubview(label)
            
            label.text = "Today's Read"
            
            return view
            
        default:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 130))
            view.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            label.text           = "For you"
            
            weak var cell = UINib(nibName: Constants.reusableSliderTableViewCell, bundle: .main).instantiate(withOwner: self, options: nil).first as? ReusableSliderTableViewCell
            
            guard let safeCell = cell else { return nil}
            
            safeCell.tapActionOnSearchButton = { [weak self] buttonText in //catch action from slider button
                self?.requestDataHandler.getDataForListNews(for: buttonText)
            }
            
            view.addSubview(label)
            view.addSubview(safeCell)
            
            
            //  label constraints
            label.translatesAutoresizingMaskIntoConstraints = false
            
            label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            
            //  button slider constraints
            safeCell.translatesAutoresizingMaskIntoConstraints = false
            safeCell.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            safeCell.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
            safeCell.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            safeCell.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            
            return view
        }
    }
}
