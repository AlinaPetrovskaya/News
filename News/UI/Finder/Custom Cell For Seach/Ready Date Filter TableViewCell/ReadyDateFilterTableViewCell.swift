//
//  ReadyDateFilterTableViewCell.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit

class ReadyDateFilterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dateForFilter: UILabel!
    @IBOutlet private weak var dateView: UIView!
    var tapAction:(() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func clearDate(_ sender: Any) {
        tapAction?()
    }
    
    private func updateUI() {
        dateView.layer.borderWidth  = 1
        dateView.layer.borderColor  = #colorLiteral(red: 0.8235294118, green: 0.8274509804, blue: 0.8470588235, alpha: 1)
        dateView.layer.cornerRadius = 8
    }
}
