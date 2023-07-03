// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.


import UIKit


//初始化
extension UIView{
    convenience init(_ color : ThemeValue) {
        self.init()
        self.themeBackgroundColor = color
    }
}

extension UIView{
    enum cornerType {
        case topLeftRight
        case bottomLeftRight
    }
    
    //处理圆角
    func dealLayer(corner:CGFloat) {
        layer.cornerRadius = corner
        layer.masksToBounds = true
    }
    
    //处理带边框的layer
    func dealBorderLayer(corner:CGFloat,bordercolor:UIColor , borderWidth : CGFloat = 1) {
        layer.borderColor = bordercolor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = corner
        layer.masksToBounds = true
    }
    
    //处理带边框的layer: 设置 corner、bordercolor、borderwidth
    func dealBorderLayer(corner:CGFloat,bordercolor:ThemeValue, borderwidth: CGFloat) {
        layer.themeBorderColor = bordercolor
        layer.borderWidth = borderwidth
        layer.cornerRadius = corner
        layer.masksToBounds = true
    }
    
    func dealCorner(type: cornerType,corner:CGFloat) {
        dealLayer(corner: corner)
        if type == .topLeftRight {
            layer.maskedCorners =  CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
        }else if type == .bottomLeftRight{
            layer.maskedCorners =  CACornerMask(rawValue: CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
        }
        
    }
    
    //绘制虚线边框
    func dealDashedLineBorderLayer(size : CGSize,corner:CGFloat,bordercolor:UIColor , borderWidth : CGFloat = 1,lineWidth : CGFloat = 3) {
        let shapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let shapePath = UIBezierPath(roundedRect: shapeRect, cornerRadius: corner)
        shapeLayer.path = shapePath.cgPath
        shapeLayer.strokeColor = bordercolor.cgColor
        shapeLayer.lineWidth = borderWidth
        shapeLayer.lineDashPattern = [NSNumber(value: lineWidth), NSNumber(value: lineWidth)]
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
    }
    
    ///渐变
    func addTopToDownGradient(colors: [CGColor], size : CGSize ,cornerRadius :CGFloat){
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.colors = colors;
        gradientLayer.cornerRadius = cornerRadius;
        gradientLayer.locations = [0.0,1.0];
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0);
        gradientLayer.endPoint = CGPoint.init(x: 0, y: 1.0);
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height);
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func addLeftToRightGradient(colors: [CGColor], size : CGSize ,cornerRadius :CGFloat){
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.colors = colors;
        gradientLayer.cornerRadius = cornerRadius;
        gradientLayer.locations = [0.0,1.0];
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0);
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0);
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height);
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    ///斜对角渐变
    func addLeftTopToRightBottomGradient(colors: [CGColor], size : CGSize ,cornerRadius :CGFloat){
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.colors = colors;
        gradientLayer.cornerRadius = cornerRadius;
        gradientLayer.locations = [0.0,1.0];
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0);
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1);
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height);
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

//处理动画
extension UIView{
    //添加动画
    class  func animationAddView(view: UIView) {
        view.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        view.alpha = 1
                        view.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                        view.transform = CGAffineTransform(scaleX: 1, y: 1)
                       }) { (_) in
            view.transform = .identity
        }
    }
    
    //移除动画
    func animationRemoveview() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { (isCompleted) in
            self.removeFromSuperview()
        }
    }
    
    func removeAllSubviews() {
        while self.subviews.count > 0 {
            self.subviews.last?.removeFromSuperview()
        }
    }
}




