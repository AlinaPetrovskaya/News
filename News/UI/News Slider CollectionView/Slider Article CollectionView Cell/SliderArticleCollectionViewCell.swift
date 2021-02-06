//
//  ReusableArticleCollectionViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit

class SliderArticleCollectionViewCell: UICollectionViewCell {
    
    var tapAction: ((Bool) -> ())?
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private weak var titleText: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    
    private var date: String?
    private var sourceName: String?
    private var urlString: String?
    private var content: String?
    private var articleDescription: String?
    private var isSaved: Bool = false

    
    func updateUI (content: DataForCell) {
        
        let isArticleSelected: String = content.isSaved ? "bookmark.fill" : "bookmark"
        saveButton.tintColor          = content.isSaved ? #colorLiteral(red: 0.417593956, green: 0.5600294471, blue: 0.9730384946, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        saveButton.setImage(UIImage(systemName: isArticleSelected), for: .normal)
        
        previewImage.image      = content.image
        titleText.text          = content.title
        self.date               = content.date
        self.sourceName         = content.sourceName
        self.isSaved            = content.isSaved
        self.articleDescription = content.articleDescription
        self.urlString          = content.urlString
        self.content            = content.content
        
        previewImage.layer.cornerRadius  = 8
        previewImage.layer.shadowColor   = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        previewImage.layer.shadowOpacity = 1
        previewImage.layer.shadowRadius  = 5.0
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        tapAction?(!isSaved)
    }
}
