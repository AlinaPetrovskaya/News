//
//  ConverterIntoString+Date.swift
//  News
//
//  Created by Alina Petrovskaya on 04.02.2021.
//

import Foundation

extension Date {
    
   enum TypeForGetDate {
        case dateForPreviewNews
        case dateForFilterButton
    }
    
    func getPreviousDate() -> Date {
        let dateFormatter = DateFormatter()
        var dayComponent  = DateComponents()
        
        dayComponent.day         = -1
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            return previousDay
        }
        
        return Date()
    }
    
    func convertDateIntoString(type: TypeForGetDate) -> String {
        let dateFormatter  = DateFormatter()
        
        switch type {
        case .dateForPreviewNews:
            dateFormatter.dateFormat = "MMM d, yyyy • HH:mm"
            return dateFormatter.string(from: self)
            
        case .dateForFilterButton:
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: self)
        }
    }
}
