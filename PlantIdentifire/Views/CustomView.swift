//
//  CustomView.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 12/06/23.
//

import UIKit

class CustomView: UIView {

    
    @IBOutlet weak var viewContent: UIView!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
