//
//  UIViewController+Extension.swift
//  PlantIdentifire
//
//  Created by admin on 09/12/22.
//

import Foundation
import UIKit
import SystemConfiguration

extension UIViewController {
    
    // show Alert Function
    
    func showAlert(withTitle title: String = "", with message: String, firstButton: String = "OK", firstHandler: ((UIAlertAction) -> Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: firstButton, style: .default, handler: firstHandler))
        present(alert, animated: true)
    }
    
    
    /**
     This method is used to check internet connectivity.
     - Returns: Return boolean value to indicate device is connected with internet or not
     */
    
     func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    //show Tost
     func showToast(message : String, height: Int = 35) {

          let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - 200) / 2, y: self.view.frame.size.height-100, width: 200, height: 60))
          toastLabel.numberOfLines = 4
          toastLabel.backgroundColor = UIColor.MyTheme.vwColor
          toastLabel.textColor = UIColor.white
          toastLabel.textAlignment = .center;
          toastLabel.text = message
          toastLabel.alpha = 1.0
          toastLabel.layer.cornerRadius = 10;
          toastLabel.clipsToBounds  =  true
          self.view.addSubview(toastLabel)
          UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
               toastLabel.alpha = 0.0
          }, completion: {(isCompleted) in
              toastLabel.removeFromSuperview()
          })
  }
    
}
