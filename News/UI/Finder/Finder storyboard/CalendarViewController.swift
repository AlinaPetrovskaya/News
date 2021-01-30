//
//  CalendarViewController.swift
//  News
//
//  Created by Alina Petrovskaya on 30.12.2020.
//

import UIKit

class CalendarViewController: UIViewController {
    
    var callBack: ((Date) -> ())?
    
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, yyyy"
        callBack?(sender.date)
    }
    
    
    @IBAction func dismissStoryboard(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
