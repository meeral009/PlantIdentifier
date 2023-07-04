//
//  PlantDetiailCell.swift
//  PlantIdentifire
//
//  Created by admin on 28/11/22.
//

import UIKit

class PlantDetiailCell: UITableViewCell {
    
    //MARK: - IBoutlates
    
    @IBOutlet weak var vwImage: UIImageView!
    
    @IBOutlet weak var namePlantlabel: UILabel!
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
//    @IBOutlet weak var vwMain: GADBannerView!
    
  
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
