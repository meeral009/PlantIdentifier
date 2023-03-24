//
//  OnbordingCell.swift
//  PlantIdentifire
//
//  Created by admin on 17/11/22.
//

import UIKit

class OnbordingCell: UICollectionViewCell {

//MARK: - IBOutlates
    @IBOutlet weak var vwImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    
    func setUp(_ slide : OnboardingModel){
        
        lblTitle.text = slide.description
        vwImage.image = slide.image
        lblSubTitle.text = slide.subDescription
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
