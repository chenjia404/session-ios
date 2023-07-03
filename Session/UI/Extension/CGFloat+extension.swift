//
//  CGFloat+extension.swift
//  ICE VPN
//
//  Created by tgg on 2023/5/30.
//

import UIKit

extension CGFloat {
    //适配屏幕宽度 默认对375的宽度进行适配
//    func w() -> CGFloat{
//        return (Screen_width/375.0)*self;
//    }
    
    var w : CGFloat{
        get{
            return (Screen_width/375.0)*self
        }
    }
    
}
