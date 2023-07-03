//
//  PPZYUILabelExt.swift
//  QuPeng
//
//  Created by freyzou on 2019/3/29.
//  Copyright © 2019 com.wwsl. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(font: UIFont? = nil, textColor: ThemeValue? = nil, text: String? = nil) {
        self.init()
        if let font = font {
            self.font = font
        }
        
        if let textColor = textColor {
            self.themeTextColor = textColor
        }
        self.text = text
    }
    
    /// get the rect of substring at specific range
    func boundingRectForCharacterRange(range: NSRange) -> CGRect? {
        guard let attributedText = attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: intrinsicContentSize)
        
        textContainer.lineFragmentPadding = 0.0
        
        layoutManager.addTextContainer(textContainer)
        
        var glyphRange = NSRange()
        
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
    
    func drawUnderline(style: NSUnderlineStyle = .single, color: UIColor = UIColor.init(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)) {
        guard let attributedText = attributedText else {return}
        
        let attributedStr = NSMutableAttributedString(attributedString: attributedText)
        attributedStr.addAttributes([NSAttributedString.Key.underlineStyle : style
            , NSAttributedString.Key.underlineColor: color], range: NSRange(location: 0, length: attributedText.length))
        
        self.attributedText = attributedStr
    }
    
    func adjustLine(space: CGFloat) {
        guard let attributedText = attributedText else {return}
        let attributedStr = NSMutableAttributedString(attributedString: attributedText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        attributedStr.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: attributedText.length))
        
        self.attributedText = attributedStr
    }
    
    func setMiniLineHeight(minLineHeight: CGFloat = 25,aligenment: NSTextAlignment = .left) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = minLineHeight
        paragraphStyle.alignment = aligenment

        let attrString = NSMutableAttributedString(string: text ?? "")
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attrString.length))
        attributedText = attrString
    }
    
    func getSeparatedLines(_ rect : CGRect) -> [String]{
        let text = self.text ?? ""
        let font = self.font ?? UIFont()
        let attStr = NSMutableAttributedString.init(string: text)
        attStr.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attStr.length))
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr)
        let path = CGMutablePath();
        path.addRect(CGRect.init(x: 0, y: 0, width: rect.width, height: 10000))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as Array
        let nsStr = NSString.init(string: text)
        var linesArr : [String] = []
        for line in lines{
            let lineRef = line as! CTLine
            let lineRang = CTLineGetStringRange(lineRef)
            let rang = NSMakeRange(lineRang.location, lineRang.length)
            let lineStr = nsStr.substring(with: rang)
            linesArr.append(lineStr)
        }
        return linesArr
    }
    
    func getSeparatedLines(_ rect : CGRect,html : NSMutableAttributedString) -> [String]{
        let attStr = html
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr)
        let path = CGMutablePath();
        path.addRect(CGRect.init(x: 0, y: 0, width: rect.width, height: 10000))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as Array
        let nsStr = NSString.init(string: attStr.string)
        var linesArr : [String] = []
        for line in lines{
            let lineRef = line as! CTLine
            let lineRang = CTLineGetStringRange(lineRef)
            let rang = NSMakeRange(lineRang.location, lineRang.length)
            let lineStr = nsStr.substring(with: rang)
            linesArr.append(lineStr)
        }
        return linesArr
    }
}

extension UILabel {
	@discardableResult
	func text(_ text: String?) -> Self {
		self.text = text
		return self
	}
    
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }
	
	@discardableResult
	func textColor(_ color: UIColor) -> Self {
		textColor = color
		return self
	}
	
	@discardableResult
	func font(_ size: CGFloat, weight: UIFont.Weight = .medium) -> Self {
		self.font = UIFont.systemFont(ofSize: size, weight: weight)
		return self
	}
	
	@discardableResult
	func textAlignment(_ alignment: NSTextAlignment) -> Self {
		textAlignment = alignment
		return self
	}
	
	@discardableResult
	func numLines(_ lines: Int) -> Self {
		numberOfLines = lines
		return self
	}
    
    @discardableResult
    func lineBreakingMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }
}
