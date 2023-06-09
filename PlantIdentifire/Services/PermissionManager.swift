//
//  PermissionManager.swift
//  Contact Backup
//
//  Created by iMac on 16/06/21.
//

import UIKit
import Photos

class PermissionManager: NSObject {
    // static let shared = PermissionManager()
    
    // MARK: - Camera Permission
    func isCameraPemissionGranted() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }
    
    func checkCameraPermission(completionHandler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .authorized:
                DispatchQueue.main.async { completionHandler() }
                
            case .denied:
                DispatchQueue.main.async {
                    self.showPermissionAlert(title: "Can't access camera", msg: "Please go to Settings -> MyApp to enable camera permission")
                }
                
            case .restricted, .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    if granted {
                        DispatchQueue.main.async { completionHandler() }
                    } else {
                        DispatchQueue.main.async {
                            self.showPermissionAlert(title: "Can't access camera", msg: "Please go to Settings -> MyApp to enable camera permission")
                        }
                    }
                }
                
            @unknown default:
                fatalError("Camera Permission Error")
        }
    }
    
    
    
    // Permission Alert Dialog
    
    func showPermissionAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Setting", style: UIAlertAction.Style.default, handler: { (ACTION) in
            guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
    }

}

