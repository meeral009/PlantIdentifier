//
//  Extension.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 01/06/23.
//

import Foundation
import UIKit

extension UIDevice {
    /// Returns `true` if the device has a notch
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            // Fallback on earlier versions
            let bottom = UIApplication.shared.keyWindow?.layoutMargins.bottom ?? 0
            return bottom > 0
        }
    }
    
    var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isTV: Bool {
        return UIDevice.current.userInterfaceIdiom == .tv
    }

    var isCarPlay: Bool {
        return UIDevice.current.userInterfaceIdiom == .carPlay
    }
}


extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}


extension Array {
    mutating func remove(at indexes: [Int]) {
        var lastIndex: Int? = nil
        for index in indexes.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }
}
