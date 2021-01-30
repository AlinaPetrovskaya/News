//
//  ReusableArticleTableViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit

class ReusableArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet private weak var titleText: UILabel!
    @IBOutlet private weak var dateText: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    
    private var sourceName: String?
    private var urlString: String?
    private var content: String?
    private var articleDescription: String?
    private var isSaved: Bool = false
    
    var tapAction: ((Bool) -> ())?
    
    var getInfoFromCell: (image: UIImage?,
                          title: String?,
                          sourceName: String?,
                          urlString: String?,
                          content: String?,
                          articleDescription: String?) {
        get {
            return ((image: previewImage.image,
                     title: titleText.text,
                     sourceName: sourceName,
                     urlString: urlString,
                     content: content,
                     articleDescription: articleDescription))
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        tapAction?(!isSaved)
    }
    
    
    func updateUI(title: String?,
                  date: String?,
                  sourceName: String?,
                  urlString: String?,
                  content: String?,
                  articleDescription: String?,
                  isSaved: Bool = false) {
        
        let isArticleSelected: String = isSaved ? "bookmark.fill" : "bookmark"
        saveButton.tintColor    = isSaved ? #colorLiteral(red: 0.417593956, green: 0.5600294471, blue: 0.9730384946, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        saveButton.setImage(UIImage(systemName: isArticleSelected), for: .normal)
        
        
        titleText.text          = title
        dateText.text           = date
        self.articleDescription = articleDescription
        self.isSaved            = isSaved
        self.sourceName         = sourceName
        self.urlString          = urlString
        self.content            = content
    
        previewImage.layer.cornerRadius = 8
        
    }
}
