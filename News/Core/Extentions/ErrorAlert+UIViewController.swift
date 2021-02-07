//
//  ErrorAlert+UIViewController.swift
//  News
//
//  Created by Alina Petrovskaya on 07.02.2021.
//

import UIKit

extension UIViewController {
    
    func errorAlertShow(error: Error) {
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription , preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Close", style: .cancel) { _ in
            return
        }
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
}
