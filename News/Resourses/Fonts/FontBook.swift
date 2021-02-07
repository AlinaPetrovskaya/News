//
//  Extention+Font.swift
//  News
//
//  Created by Alina Petrovskaya on 07.02.2021.
//

import UIKit

    enum FontBook: String  {
        case PlayFairMedium  = "PlayfairDisplay-Medium"
        case PlayFairRegular = "PlayfairDisplay-Regular"
        case PlayFairBold    = "PlayfairDisplay-Bold"
        
        case SPFTextMedium  = "SF Pro Text Medium"
        case SPFTextRegular = "SF Pro Text Regular"
        case SPFTextBold    = "SF Pro Text Semibold"
        
        case SPFDisplayMedium  = "SF Pro Display Medium"
        case SPFDisplayRegular = "SF Pro Display Regular"
        case SPFDisplayBold    = "SF Pro Display Semibold"
        
        case PoppinsMedium  = "Poppins Medium"
        case PoppinsRegular = "Poppins Regular"
        case PoppinsBold    = "Poppins SemiBold"
        

        func of (size: CGFloat) -> UIFont {
            return UIFont(name: self.rawValue, size: size)!
          }
    }
    
