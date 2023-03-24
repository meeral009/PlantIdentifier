//
//  GoogleNativeAdsCustomeView3.swift
//  Simple Demo
//
//  Created by Sagar Lukhi on 27/12/22.
//

import UIKit
import GoogleMobileAds

class GoogleNativeAdsCustomeView3: UIView {
    
    // OUTLET
    @IBOutlet var adUIView: GADNativeAdView!
    @IBOutlet weak var nativeAdsWidth: NSLayoutConstraint!
    
    // VARIABLE
    var nativeAd: GADNativeAd = GADNativeAd()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GoogleNativeAdsCustomeView3", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods
    func setup() {
        
        let adView = self.adUIView
        adView?.nativeAd = nativeAd
        adView?.mediaView?.mediaContent = nativeAd.mediaContent
        adView?.mediaView?.contentMode = .scaleAspectFill
        (adView?.headlineView as? UILabel)?.text = nativeAd.headline
        (adView?.bodyView as? UILabel)?.text = "\t\(nativeAd.body ?? "")"
        (adView?.iconView as? UIImageView)?.clipsToBounds = true
        (adView?.iconView as? UIImageView)?.layer.cornerRadius = 5
        (adView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (adView?.callToActionView as? UIButton)?.isUserInteractionEnabled = false
        (adView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (adView?.callToActionView as? UIButton)?.layer.cornerRadius = 4
        
        let data = (adView?.iconView as? UIImageView)?.image?.pngData()
        if data == nil {
            nativeAdsWidth.constant = 0
        }
        
        
    }
}
