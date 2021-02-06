//
//  BookmarksViewController.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit
import RealmSwift

class BookmarksViewController: UIViewController {
    
    @IBOutlet weak var articleTable: UITableView!
    
    private var items: Results<RealmItem>?
    private var itemsToken: NotificationToken?
    private var dataForDetailVC: DataForArticle?
    
    private let dbManager    = DBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = RealmItem.getAllItems()
        
        articleTable.delegate   = self
        articleTable.dataSource = self
        
        let nib = UINib(nibName: Constants.articleTableViewCell, bundle: .main)
        
        articleTable.register(nib, forCellReuseIdentifier: Constants.articleTableViewCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        itemsToken = items?.observe({ [weak articleTable] changes in
          
          switch changes {
          
          case .initial:
            articleTable?.reloadData()
           
          case .update(_, _, _, _):
            articleTable?.reloadData()
            
          case .error:
            break
          }
        })
        
      }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
        itemsToken?.invalidate()
      
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.fromBookmarksToArticle {
            weak var vc = segue.destination as? ArticleDetailController
            vc?.dataForDetailArticle = dataForDetailVC
            
        } 
    }
}

// MARK: UITableViewDataSource
extension BookmarksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = articleTable.dequeueReusableCell(withIdentifier: Constants.articleTableViewCell) as? ArticleTableViewCell
        
        guard let contentForCell = items?[indexPath.row] else { return UITableViewCell() }
        
        let date = contentForCell.date.convertDateIntoString(type: .dateForPreviewNews)
        let image = dbManager.getImageForBookmarkArticle(imageUrl: contentForCell.imageURL)
        let dataConstructor = (image: image,
                               title: contentForCell.title,
                               date: date,
                               sourceName: contentForCell.sourceName,
                               urlString: contentForCell.urlString,
                               content: contentForCell.content,
                               articleDescription: contentForCell.articleDescription,
                               isSaved: true)
        
        cell?.updateUI(content: dataConstructor)
        
        //get action from cell
        cell?.tapAction = { [weak self] _ in
            let item = self?.items?[indexPath.row]
            DispatchQueue.main.async {
                ImageManager.deleteImageFromFileManager(imageURL: item?.imageURL)
                self?.articleTable.updateItemAtRealm(data: nil, needSave: false, item: item)
            }
        }
      
        return cell ?? UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension BookmarksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contentForArticleDetail = items?[indexPath.row]
        
                dataForDetailVC = (image: #imageLiteral(resourceName: "default"),
                                   title: contentForArticleDetail?.title,
                                   sourceName: contentForArticleDetail?.sourceName,
                                   urlString: contentForArticleDetail?.urlString,
                                   content: contentForArticleDetail?.content,
                                   articleDescription: contentForArticleDetail?.articleDescription)
        
        if let imageURL = contentForArticleDetail?.imageURL {
            let image = dbManager.getImageForBookmarkArticle(imageUrl: imageURL)
            dataForDetailVC?.image = image
        }

        performSegue(withIdentifier: Constants.fromBookmarksToArticle, sender: self)
    }
}
