//
//  PlantCell.swift
//  PlantIdentifire
//
//  Created by Miral's iMac on 28/04/23.
//

import UIKit

class PlantCell: UICollectionViewCell {

    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var lblfamilyName: UILabel!
    @IBOutlet var lblPlantName: UILabel!
    @IBOutlet var imgPlant: UIImageView!
    
    @IBOutlet var btnSelect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
   //     self.btnSelect.addTarget(self, action: #selector(onClickSelect(_:)), for: .touchUpInside)
    }

    
//    @objc func onClickSelect(_ sender: UIButton) {
//        if self.btnSelect.isSelected {
//            self.btnSelect.isSelected = false
//        } else {
//            self.btnSelect.isSelected = true
//        }
//    }
}
