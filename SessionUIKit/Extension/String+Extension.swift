//
//  String+Extension.swift
//  ICE VPN
//
//  Created by tgg on 2023/5/23.
//

import UIKit

extension String{
    //转化为Int
    func toInt()->Int {
        var int = 0
        if(self.count > 0){
            if let intValue = Int(self)
            {
                int = intValue
            }
        }
        return int
    }
    
    func toDouble()->Double {
        var double : Double = 0
        if(self.count > 0){
            var value = self
            value = value.removeComma()
            if let doubleValue = Double(value)
            {
                double = doubleValue
                if double.isNaN {
                    double = 0
                }
            }
        }
        
        return double
    }
    
    func toDictionary()->[String:Any]?{
        
        if let data = self.data(using: .utf8){
            do {
                let ay = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                return ay as? [String : Any]
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func toArray()->[Any]?{
        
        if let data = self.data(using: .utf8){
            do {
                let ay = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                return ay as? [Any]
            } catch {
                return nil
            }
        }
        return nil
    }
    
    
    func removeString(_ deleteValue : String) -> String{
        var value = self
        value = value.replacingOccurrences(of: deleteValue, with: "")
        return value
    }
    
    func removeComma() -> String{
        return removeString(",")
    }
    
    //去除字符串中的空格
    func removeSpace() -> String {
        return removeString(" ")
    }
    
    //生成随机字符串
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension String{
    var add0x: String {
        if hasPrefix("0x") {
            return self
        } else {
            return "0x" + self
        }
    }
    
    func urlHost() -> String {
        var host = self.components(separatedBy: "?").first
        host = host?.replacingOccurrences(of: "https://", with: "")
        host = host?.replacingOccurrences(of: "http://", with: "")
        host = host?.components(separatedBy: "/").first
        return host ?? ""
    }
    
    ///多语言字符串替换 将%s替换为指定字符串
    func languageUpdate(_ strings : [String]) -> String {
        var str = self
        var index = 0
        while (str.range(of: "%s") != nil) {
            let rang = str.range(of: "%s")
            if index >= strings.count  {
                return str
            }
            str = str.replacingCharacters(in: rang!, with: strings[index])
            index += 1;
        }
        return str
    }
    
    //获取width度
    func width(_ size : CGSize, font : UIFont) -> CGFloat {
        let att = [NSAttributedString.Key.font:font]
        let size = self.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin,attributes:att, context: nil).size
        
        return size.width
    }
    
    func showAddress(_ lenght : Int = 11) -> String {
        var str = self
        if str.count > lenght * 2 {
            str = self.prefix(lenght) + "..." + self.suffix(lenght)
        }
        return str
    }
}

//验证
extension String{
    func checkEmail() -> Bool{
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return emailTest.evaluate(with: self)
    }
    
    func checkPwd() -> Bool {
        let pwd =  "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$"
        let regextestpwd = NSPredicate(format: "SELF MATCHES %@",pwd)
        return regextestpwd.evaluate(with: self)
    }
    
    func checkCode() -> Bool {
        let code = "^[0-9]{6}$"
        let regextest = NSPredicate(format: "SELF MATCHES %@",code)
        return regextest.evaluate(with: self)
    }
}

extension String {
    func changeColor(_ color: UIColor,
                     range: NSRange,
                     origin: [NSAttributedString.Key : Any]?) -> NSMutableAttributedString {
        let mStr = NSMutableAttributedString(string: self, attributes: origin)
        mStr.setAttributes([NSAttributedString.Key.foregroundColor : color], range: range)
        
        return mStr
    }
}


///Decimal
extension String{
    //除
    func decimal() -> Decimal {
        
        var value = self
        if value == ""{
            value = "0"
        }
        value = value.removeComma()
        guard let number1 = Decimal(string:value) else { return Decimal(string: "0")! }
        return number1
    }
    
    //加
    func add(numberString:String) -> String {
        var value = self
        if value == ""{
            value = "0"
        }
        var num = numberString
        if num == ""{
            num = "0"
        }
        value = value.removeComma()
        guard let number1 = Decimal(string:value) else { return "0" }
        guard let number2 = Decimal(string: num) else { return "0" }
        let summation = number1 + number2
        return "\(summation)"
    }
    
    //减
    func reduction(numberString:String) -> String {
        var value = self
        if value == ""{
            value = "0"
        }
        var num = numberString
        if num == ""{
            num = "0"
        }
        value = value.removeComma()
        guard let number1 = Decimal(string:value) else { return "0" }
        guard let number2 = Decimal(string: num) else { return "0" }
        let summation = number1 - number2
        return "\(summation)"
    }
    
    //乘
    func take(numberString:String) -> String {
        var value = self
        if value == ""{
            value = "0"
        }
        var num = numberString
        if num == ""{
            num = "0"
        }
        value = value.removeComma()
        guard let number1 = Decimal(string:value) else { return "0" }
        guard let number2 = Decimal(string: num) else { return "0" }
        let summation = number1 * number2
        return "\(summation)"
    }
    
    //除
    func division(numberString:String) -> String {
        var value = self
        if value == ""{
            value = "0"
        }
        var num = numberString
        if num == ""{
            num = "0"
        }
        value = value.removeComma()
        guard let number1 = Decimal(string:value) else { return "0" }
        guard let number2 = Decimal(string: num) else { return "0" }
        let summation = number1 / number2
        return "\(summation)"
    }
    
    ///给数字加逗号
    func conversionDecimail() -> String{
        let value = self
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let result = formatter.string(from: NSNumber.init(value: value.toDouble()))
        return result ?? ""
    }
    
    func cleanZero(_ min : Int = 18) -> String{
        let value = self.toDouble()
        var result = self
        if value == 0{
            return "0.00"
        }
        let absValue = fabs(value)
        if absValue < 0.00000001{
            if min == 8{
                return String(format: "%.8f", value)
            }
            result = String(format: "%.18f", value)
        }else
        if absValue < 1 {
            result = String(format: "%.8f", value)
        }else if absValue > 1000 {
            result = String(format: "%.2f", value).conversionDecimail()
            return result
        }else if absValue > 10 {
            result = String(format: "%.4f", value)
        }else if absValue > 1 {
            result = String(format: "%.6f", value)
        }
        guard let number1 = Decimal(string:result) else {return ""}
        return "\(number1)"
    }
}

extension String {
    //时间戳转到字符串
    func timeStampToStringStyle()->String {
        let string = NSString(string: self)
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        let date = NSDate(timeIntervalSince1970: timeSta)
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dfmatter.string(from: date as Date)
    }
    
    //时间戳转到字符串
    func toyyyyMMdd(_ dateFormat : String = "yyyy-MM-dd")->String {
        
        let string = NSString(string: self)
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        let date = NSDate(timeIntervalSince1970: timeSta)
        dfmatter.dateFormat = dateFormat
        return dfmatter.string(from: date as Date)
    }
    
    //将字符串转换为时间戳
    func toTimeStampStr() -> String {
        let datefmatter = DateFormatter()
        datefmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        let date = datefmatter.date(from: self)
        let dateStamp:TimeInterval = date!.timeIntervalSince1970
        let dateStr:Int = Int(dateStamp) * 1000
        return "\(dateStr)"
    }
    
    
    
    func toDoubleTimeStamp() -> Double {
        let datefmatter = DateFormatter()
        datefmatter.dateFormat="yyyy-MM-dd HH:mm"
        if let date = datefmatter.date(from: self){
            let dateStamp:TimeInterval = date.timeIntervalSince1970
//            let dateStr:Int = Int(dateStamp) * 1000
            return Double(dateStamp)
        }
        return 0.0
    }
    
    func toTimeStampDate() -> NSDate{
        let string = NSString(string: self)
        let timeSta:TimeInterval = string.doubleValue
        let date = NSDate(timeIntervalSince1970: timeSta)
        return date
    }
    
}
