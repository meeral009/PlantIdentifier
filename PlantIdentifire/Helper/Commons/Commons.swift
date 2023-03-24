//
//  Commons.swift
//  PlantIdentifire
//
//  Created by admin on 28/11/22.
//

import Foundation
import UIKit
import GoogleMobileAds

var arrId = [String]()

var arrOfObjectsOfImage = [Images]()

let appDelegate = UIApplication.shared.delegate as! AppDelegate

enum URLTypes: String {
    
    case contactUs = "https://pipaliyasmit.wordpress.com/contactus/"
    case privacyPolicy = "https://swainfosolution.wordpress.com/privacy-policy/"
    case shareApp = "https://apps.apple.com/in/app/blood-pressure-tracker/id6443948898"
    
}

enum adMob: String {
    
// //    Production
//    case bannerAdID = "ca-app-pub-8252529408738635/7601503906"
//    case interstitialAdID = "ca-app-pub-8252529408738635/6436332717"
//    case nativeAdID = "ca-app-pub-8252529408738635/5410454834"

//    // Development
   case bannerAdID = "ca-app-pub-3940256099942544/2934735716"
    case interstitialAdID = "ca-app-pub-3940256099942544/4411468910"
    case nativeAdID = "ca-app-pub-3940256099942544/3986624511"
    
    case openAdID = "ca-app-pub-3940256099942544/5662855259"
//
    
//    struct GOOGLE_ADS { // Google Testing Ads
//        static var AppId            = "ca-app-pub-3940256099942544~1458002511"
//        static var OpenAds          = "ca-app-pub-3940256099942544/5662855259"
//        static var BannerAds        = "ca-app-pub-3940256099942544/2934735716"
//        static var NativeAds        = "ca-app-pub-3940256099942544/3986624511"
//        static var InterstitialAds  = "ca-app-pub-3940256099942544/4411468910"
//    }
    
    
}
