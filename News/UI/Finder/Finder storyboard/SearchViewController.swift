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
    private var requestDataHandler            = RequestDataHandler()
    private var articleBrain                  = ArticleBrain()
    private let dbManager                     = DBManager()
   
    private var items: Results<RealmItem>?
    private var itemsToken: NotificationToken?
    private var currentcell: (Int, Int)?
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var articleTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var dateForFilter: (dateFrom: Date, dateTo: Date) = (dateFrom: Date(), dateTo: Date()) {
        didSet {
            reloadTableView(qualifierOfTypeCell: .prepareDate)
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = RealmItem.getAllItems()
        searchTextField.delegate = self
        
        prepareUI()
        prepareTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      
      itemsToken?.invalidate()

    }
    
    private func prepareUI() {
        //get callback from requestDataHandler
        requestDataHandler.callBack = { [weak self] in
            self?.articleBrain.images = self?.requestDataHandler.dictionaryOfimages ?? [:]
            self?.reloadTableView(qualifierOfTypeCell: self?.qualifierOfTypeCell ?? .readyDate)
            self?.activityIndicator.alpha = 0
        }
        
        dateForFilter.dateFrom = articleBrain.getPreviousDate()
        
        searchTextField.layer.cornerRadius = 10
        searchButton.layer.cornerRadius    = 4
    }
    
    private func prepareTableView() {
        articleTable.delegate   = self
        articleTable.dataSource = self
        
        articleTable.register(UINib(nibName: Constants.prepareDateFilterCell, bundle: .main), forCellReuseIdentifier: Constants.prepareDateFilterCell)
        articleTable.register(UINib(nibName: Constants.readyDateFilterCell, bundle: .main), forCellReuseIdentifier: Constants.readyDateFilterCell)
        articleTable.register(UINib(nibName: Constants.reusableArticleCell, bundle: .main), forCellReuseIdentifier: Constants.reusableArticleCell)
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
        let indexPath = articleTable.indexPathForSelectedRow
        guard let index = indexPath else { return }
        
        if segue.identifier == Constants.fromSearchToArticle {
            
            if let vc = segue.destination as? ArticleDetailController {
                
                switch index.section {
                case 0:
                    break
                    
                default:
                    let cell = articleTable.cellForRow(at: index) as? ReusableArticleTableViewCell
                    vc.dataForDetailArticle = cell?.getInfoFromCell
                }
            }
        }
    }
    
    // MARK: Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestDataHandler.getDataFromFilter(for: searchTextField.text, dateFrom: dateForFilter.dateFrom, dateTo: dateForFilter.dateTo)
        reloadTableView(qualifierOfTypeCell: .readyDate)
        return true
    }
        
    @IBAction private func searchButtonTapped(_ sender: UIButton) {
        requestDataHandler.getDataFromFilter(for: searchTextField.text, dateFrom: dateForFilter.dateFrom, dateTo: dateForFilter.dateTo)
        reloadTableView(qualifierOfTypeCell: .readyDate)
    }
    
    private func reloadTableView(qualifierOfTypeCell: TypeCell) {
        self.qualifierOfTypeCell = qualifierOfTypeCell
        articleBrain.images = requestDataHandler.dictionaryOfimages
        
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
            return requestDataHandler.arrayForListOfArticles.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var buttonFromText: String {
            return articleBrain.convertDateIntoString(date: dateForFilter.dateFrom, type: .dateForFilterButton)
        }
        
        var buttonToText: String {
            return articleBrain.convertDateIntoString(date: dateForFilter.dateTo, type: .dateForFilterButton)
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
            let cell            = articleTable.dequeueReusableCell(withIdentifier: Constants.reusableArticleCell) as? ReusableArticleTableViewCell
            let contentForCell  = requestDataHandler.arrayForListOfArticles[indexPath.row]
            
            let newCell         =  articleBrain.buildCellForArticleTable(cell: cell, contentForCell: contentForCell)
            
            //catch save action
            newCell.tapAction = { [weak self] needSave in
                self?.currentcell = (indexPath.row, indexPath.section)
                
                let imageData = self?.requestDataHandler.dictionaryOfimages[contentForCell.urlToImage ?? ""]
                let contentForRealm = self?.dbManager.prepareDateForRealm(item: contentForCell, image: imageData)
                if needSave {
                        
                    self?.articleTable.updateItemAtRealm(data: contentForRealm, needSave: true, item: nil)
                    
                } else {
                    let item = self?.dbManager.getRealmItem(urlString: contentForCell.urlString)
                    self?.dbManager.deleteImageFromFileManager(imageURL: item?.imageURL)
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
        let view = UIView(frame: CGRect(x: 24, y: 0, width: tableView.frame.width, height: 50))
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let label = UILabel(frame: CGRect(x: 24, y: 10, width: tableView.frame.width, height: 50))
        view.addSubview(label)
        
        label.font = UIFont(name: "Poppins Medium", size: 18)
        
        switch qualifierOfTypeCell {
        case .prepareDate:
            label.text = "Filter"
            return view
            
        default:
            return nil
        }
    }
}
