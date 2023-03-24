//
//  UIView+Extension.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import Foundation
import UIKit

extension UIView {
    
    func customView(){
        
        //To apply corner radius
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.MyTheme.bgColor.cgColor

    }

      func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
      }

}
