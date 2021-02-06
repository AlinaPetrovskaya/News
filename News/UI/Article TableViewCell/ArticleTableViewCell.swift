//
//  ArticleTableViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var previewImage: UIImageView!
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
    
    
    func updateUI(content: DataForCell) {
        
        let isArticleSelected: String = content.isSaved ? "bookmark.fill" : "bookmark"
        saveButton.tintColor          = content.isSaved ? #colorLiteral(red: 0.417593956, green: 0.5600294471, blue: 0.9730384946, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        saveButton.setImage(UIImage(systemName: isArticleSelected), for: .normal)
        
        previewImage.image      = content.image
        titleText.text          = content.title
        dateText.text           = content.date
        self.articleDescription = content.articleDescription
        self.isSaved            = content.isSaved
        self.sourceName         = content.sourceName
        self.urlString          = content.urlString
        self.content            = content.content
    
        previewImage.layer.cornerRadius = 8
    }
}
