// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.


import UIKit

extension UITextField {
    //设置padding
    func setTextFildPadding(leftwidth: CGFloat) {
        var frame = self.frame
        frame.size.width = leftwidth
        let the_leftview = UIView(frame: frame)
        self.leftViewMode = .always
        self.leftView = the_leftview
    }
    
    func addLeftView(_ height : CGFloat ,width : CGFloat = 20.w){
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
        self.leftViewMode = .always
        self.leftView = view
    }
    
    func addLeftView(_ view : UIView){
        self.leftViewMode = .always
        self.leftView = view
    }
    
}

///初始化
extension UITextField {
    convenience init(_ placeholder : String? = nil , font : UIFont? = nil , textColor : ThemeValue? = nil,text: String = "") {
        self.init()
        if let font = font {
            self.font = font
        }
        if let textColor = textColor {
            self.themeTextColor = textColor
        }
        self.text = text
        if let placeholder = placeholder {
            ThemeManager.onThemeChange(observer: self) { [weak self] theme, _ in
                guard let textColor: UIColor = theme.color(for: .textSecondary) else { return }
                self?.attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [
                        .foregroundColor: textColor
                    ])
            }
        }
        
    }
    
    func addPlaceholder(_ placeholder :String)  {
        ThemeManager.onThemeChange(observer: self) { [weak self] theme, _ in
            guard let textColor: UIColor = theme.color(for: .textSecondary) else { return }
            self?.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: textColor
                ])
        }
    }
    
    ///显示完成收起键盘
//    func showDone() {
////        self.textInputMode
//        let view = FWDoneInputView(frame: CGRect.init(x: 0, y: 0, width: Screen_width, height: 45))
//        view.doneBlock = {
//            self.resignFirstResponder()
//        }
//        self.inputAccessoryView = view
//    }
    
}

