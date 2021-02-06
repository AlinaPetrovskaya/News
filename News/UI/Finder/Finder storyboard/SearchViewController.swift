//
//  SearchViewController.swift
//  News
//
//  Created by Alina Petrovskaya on 24.12.2020.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    private enum TypeCell: Int {
        case prepareDate = 0, readyDate
    }
    
    private var qualifierOfTypeCell: TypeCell = .prepareDate
    private var requestDataWrapper            = RequestDataWrapper()
    private var articleContentBuilder         = ArticleContentBuilder()
    private let dbManager                     = DBManager()
   
    private var items: Results<RealmItem>?
    private var itemsToken: NotificationToken?
    private var currentcell: (Int, Int)?
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var articleTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var dateForFilter: (dateFrom: Date, dateTo: Date) = (dateFrom: Date().getPreviousDate(), dateTo: Date()) {
        didSet {
            reloadTableView(qualifierOfTypeCell: .prepareDate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = RealmItem.getAllItems()
        searchTextField.delegate = self
        
        prepareUI()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemsToken = items?.observe({ [weak articleTable, weak self] changes in
            
            switch changes {
            
            case .initial:
                break
                
            case .update(_, _, _, _):
                if let cell = self?.currentcell {
                    articleTable?.reloadRows(cell: [cell])
                }
                
            case .error:
                break
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      
      itemsToken?.invalidate()

    }
    
    private func prepareUI() {
        //get callback from requestDataHandler
        requestDataWrapper.callBack = { [weak self] in
            self?.articleContentBuilder.images = self?.requestDataWrapper.dictionaryOfimages ?? [:]
            self?.reloadTableView(qualifierOfTypeCell: self?.qualifierOfTypeCell ?? .readyDate)
            self?.activityIndicator.alpha = 0
        }
        
        searchTextField.layer.cornerRadius = 10
        searchButton.layer.cornerRadius    = 4
    }
    
    private func prepareTableView() {
        articleTable.delegate   = self
        articleTable.dataSource = self
        
        articleTable.register(UINib(nibName: Constants.prepareDateFilterCell, bundle: .main), forCellReuseIdentifier: Constants.prepareDateFilterCell)
        articleTable.register(UINib(nibName: Constants.readyDateFilterCell, bundle: .main), forCellReuseIdentifier: Constants.readyDateFilterCell)
        articleTable.register(UINib(nibName: Constants.articleTableViewCell, bundle: .main), forCellReuseIdentifier: Constants.articleTableViewCell)
    }
    
    private func getDateFromCalendar(for buttonFrom: Bool) { //present calendar
        
        let storyboard          = UIStoryboard(name: Constants.searchVC, bundle: nil)
        weak var viewController = storyboard.instantiateViewController(identifier: Constants.calendarVC) as? CalendarViewController
        
        if let vc = viewController {
            vc.callBack = { [weak self] date in
                if buttonFrom {
                    self?.dateForFilter.dateFrom = date
                } else {
                    self?.dateForFilter.dateTo = date
                }
            }
            
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle   = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = articleTable.indexPathForSelectedRow else { return }
        
        if segue.identifier == Constants.fromSearchToArticle {
            if let vc = segue.destination as? ArticleDetailController {
                
                switch index.section {
                case 0:
                    break
                    
                default:
                    let cell = articleTable.cellForRow(at: index) as? ArticleTableViewCell
                    vc.dataForDetailArticle = cell?.getInfoFromCell
                }
            }
        }
    }
    
    // MARK: Actions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestDataWrapper.getDataFromFilter(for: searchTextField.text, dateFrom: dateForFilter.dateFrom, dateTo: dateForFilter.dateTo)
        reloadTableView(qualifierOfTypeCell: .readyDate)
        return true
    }
        
    @IBAction private func searchButtonTapped(_ sender: UIButton) {
        requestDataWrapper.getDataFromFilter(for: searchTextField.text, dateFrom: dateForFilter.dateFrom, dateTo: dateForFilter.dateTo)
        reloadTableView(qualifierOfTypeCell: .readyDate)
    }
    
    private func reloadTableView(qualifierOfTypeCell: TypeCell) {
        self.qualifierOfTypeCell = qualifierOfTypeCell
        articleContentBuilder.images = requestDataWrapper.dictionaryOfimages
        
        articleTable.reloadData()
        activityIndicator.alpha = qualifierOfTypeCell.rawValue == 0 ? 0 : 1
    }
}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch qualifierOfTypeCell {
        case .prepareDate:
            return 1
        case .readyDate :
            return 2
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return requestDataWrapper.arrayForListOfArticles.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var buttonFromText: String {
            return  dateForFilter.dateFrom.convertDateIntoString(type: .dateForFilterButton)
        }
        
        var buttonToText: String {
            return dateForFilter.dateTo.convertDateIntoString(type: .dateForFilterButton)
        }
        
        switch indexPath.section {
        case 0 : /// date filter
            
            switch qualifierOfTypeCell {
            case .prepareDate:
                
                let prepareDateCell = articleTable.dequeueReusableCell(withIdentifier: Constants.prepareDateFilterCell) as? PrepareDateFilterTableViewCell
                
                
                prepareDateCell?.buttonDateFrom.setTitle(buttonFromText, for: .normal)
                prepareDateCell?.buttonDateTo.setTitle(buttonToText, for: .normal)
                
                //catch tap action from dateButton PrepareDateFilterTableViewCell
                prepareDateCell?.tapAction = {[weak self] button in
                    self?.getDateFromCalendar(for: button) //perform calendar
                }
                
                return prepareDateCell ?? UITableViewCell()
                
                
            case .readyDate:
                
                let readyDateCell = articleTable.dequeueReusableCell(withIdentifier: Constants.readyDateFilterCell) as? ReadyDateFilterTableViewCell
                readyDateCell?.tapAction = { [weak self] in
                    self?.reloadTableView(qualifierOfTypeCell: .prepareDate)
                }
                
                readyDateCell?.dateForFilter.text = buttonFromText + " - " + buttonToText
                return readyDateCell ?? UITableViewCell()
            }
            
        default: ///preview news list
            let cell            = articleTable.dequeueReusableCell(withIdentifier: Constants.articleTableViewCell) as? ArticleTableViewCell
            let contentForCell  = requestDataWrapper.arrayForListOfArticles[indexPath.row]
            
            let newCell         =  articleContentBuilder.buildCellForArticleTable(cell: cell, contentForCell: contentForCell)
            
            //catch save action
            newCell.tapAction = { [weak self] needSave in
                self?.currentcell = (indexPath.row, indexPath.section)
                
                let imageData = self?.requestDataWrapper.dictionaryOfimages[contentForCell.urlToImage ?? ""]
                let contentForRealm = self?.dbManager.prepareDateForRealm(item: contentForCell, image: imageData)
                if needSave {
                        
                    self?.articleTable.updateItemAtRealm(data: contentForRealm, needSave: true, item: nil)
                    
                } else {
                    let item = self?.dbManager.getRealmItem(urlString: contentForCell.urlString)
                    ImageManager.deleteImageFromFileManager(imageURL: item?.imageURL)
                    self?.articleTable.updateItemAtRealm(data: nil, needSave: false, item: item)
                }
            }
            return newCell
        }
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            performSegue(withIdentifier: Constants.fromSearchToArticle, sender: self)
        default:
            print("first sections is tapped")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch qualifierOfTypeCell {
        case .prepareDate:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch qualifierOfTypeCell {
        case .prepareDate:
            let view = HeaderView(
                for: .headerForSearchListNews,
                labelText: "Filter")

            return view
            
        default:
            return nil
        }
    }
}
