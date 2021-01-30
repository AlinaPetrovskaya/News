//
//  PrepareDateFilterTableViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 24.12.2020.
//

import UIKit

class PrepareDateFilterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var buttonDateFrom: UIButton!
    @IBOutlet weak var buttonDateTo: UIButton!
    var tapAction: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp(button: buttonDateFrom)
        setUp(button: buttonDateTo)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == buttonDateFrom.titleLabel?.text {
            tapAction?(true)
        } else {
            tapAction?(false)
        }
    }

    func setUp(button: UIButton) {
        button.layer.borderWidth  = 1
        button.layer.borderColor  = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        button.layer.cornerRadius = 8
    }
}

