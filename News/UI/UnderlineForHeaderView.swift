//
//  CustomView.swift
//  News
//
//  Created by Alina Petrovskaya on 06.01.2021.
//

import UIKit

@IBDesignable
class UnderlineForHeaderView: UIView {
    override func draw(_ rect: CGRect) {
        let linePath = UIBezierPath()
        linePath.lineWidth = 2
        
        linePath.move(to: CGPoint(x: 0, y: bounds.height))
        linePath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        
        UIColor.init(cgColor: #colorLiteral(red: 0.9044558406, green: 0.8979951143, blue: 0.9094035625, alpha: 1)).setStroke()
        linePath.stroke()
    }

}
