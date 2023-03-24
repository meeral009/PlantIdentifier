//
//  UserDefaults+Extension.swift
//  PlantIdentifire
//
//  Created by admin on 28/11/22.
//

import Foundation
import UIKit

extension UserDefaults {
    
    class var isCheckOnBording : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isCheckOnBording")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isCheckOnBording")
        }
    }
    
   
    
}
