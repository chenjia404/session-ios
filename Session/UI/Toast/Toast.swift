// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import JFPopup
struct Toast {
    static func toast(hit: String){
        JFPopupView.popup.toast(hit: hit)
    }
    
    static func toast(hit: String,icon: JFToastAssetIconType){
        JFPopupView.popup.toast(hit: hit,icon: icon)
    }
    
    static func toast(hit: String , icon : String){
        JFPopupView.popup.toast(hit: hit,icon: .imageName(name: icon))
    }
    
    static func loding(){
        JFPopupView.popup.loading()
    }
    
    static func hideLoding(){
        JFPopupView.popup.hideLoading()
    }
}
