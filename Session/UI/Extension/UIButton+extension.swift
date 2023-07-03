//
//  UIButton+extension.swift
//  ICE VPN
//
//  Created by tgg on 2023/6/1.
//

import UIKit
extension UIButton{
    
    
    
    convenience init(title : String? = nil,selectTitle : String? = nil,font : UIFont? = nil , color : ThemeValue? = nil , selectColor : ThemeValue? = nil , image : UIImage? = nil , selectImage : UIImage? = nil,backgroundColor : ThemeValue? = nil, backgroundImage: UIImage? = nil, selectBackgroundImage: UIImage? = nil) {
        self.init()
        self.setTitle(title, for: UIControl.State.normal)
        if let font = font {
            self.titleLabel?.font = font
        }
        if let color = color {
            self.setThemeTitleColor(color, for: .normal)
        }
        if let selectColor = selectColor {
            self.setThemeTitleColor(selectColor, for: UIControl.State.selected)
        }
        if let image = image {
            self.setImage(image, for: UIControl.State.normal)
        }
        if let selectImage = selectImage {
            self.setImage(selectImage, for: UIControl.State.selected)
        }
        if let selectTitle = selectTitle {
            self.setTitle(selectTitle, for: UIControl.State.selected)
        }
        if let backgroundColor = backgroundColor {
            self.themeBackgroundColor = backgroundColor
        }
        if let backgroundImage = backgroundImage {
            self.setBackgroundImage(backgroundImage, for: .normal) 
        }
        if let selectBackgroundImage = selectBackgroundImage {
            self.setBackgroundImage(selectBackgroundImage, for: .selected)
        }
    }
}
