//
//  ReusableButtonCollectionViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit

class SliderButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var buttonOfArticleType: UIButton!
    var tapAction:((String) -> ())?
    
    @IBAction private func typeButtonTapped(_ sender: UIButton) {
        guard let titleOfSearchButton = sender.titleLabel?.text else { return }
        tapAction?(titleOfSearchButton)
    }
    
    func updateUI(title: String) {
        buttonOfArticleType.setTitle(title, for: .normal)
        buttonOfArticleType.layer.cornerRadius = 8
    }
}
