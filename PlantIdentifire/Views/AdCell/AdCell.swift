//
//  AdCell.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 27/03/23.
//

import UIKit
import GoogleMobileAds
class AdCell: UITableViewCell {

    @IBOutlet var adView: GADBannerView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
