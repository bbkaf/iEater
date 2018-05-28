//
//  AnimationLabel.swift
//  LabelNumbersAnimation
//
//  Created by don chen on 2017/3/9.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import UIKit

class AnimationLabel: UILabel {
    
    fileprivate var animationDuration = 2.0
    
    fileprivate var startingValue: Float = 0
    fileprivate var destinationValue: Float = 0
    fileprivate var progress: TimeInterval = 0
    
    fileprivate var lastUpdateTime: TimeInterval = 0
    fileprivate var totalTime: TimeInterval = 0
    
    fileprivate var timer: CADisplayLink?
    
    fileprivate var currentValue: Float {
        if progress >= totalTime { return destinationValue }
        return startingValue + Float(progress / totalTime) * (destinationValue - startingValue)
    }
    
    fileprivate func addDisplayLink() {
        timer = CADisplayLink(target: self, selector: #selector(self.updateValue(timer:)))
        timer?.add(to: .main, forMode: .defaultRunLoopMode)
        timer?.add(to: .main, forMode: .UITrackingRunLoopMode)
    }
    
    @objc fileprivate func updateValue(timer: Timer) {
        let now: TimeInterval = Date.timeIntervalSinceReferenceDate
        progress += now - lastUpdateTime
        lastUpdateTime = now
        
        if progress >= totalTime {
            self.timer?.invalidate()
            self.timer = nil
            progress = totalTime
        }
        
        setTextValue(value: currentValue)
    }
    
    // update UILabel.text
    fileprivate func setTextValue(value: Float) {
        text = String(format: "👣%.0f", value)
    }
    

    
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

// MARK: Counting Method
extension AnimationLabel {
    func count(from: Float, to: Float, duration: TimeInterval? = nil) {
        startingValue = from
        destinationValue = to
        
        timer?.invalidate()
        timer = nil
        
        if (duration == 0.0) {
            // No animation
            setTextValue(value: to)
            return
        }
        
        progress = 0.0
        totalTime = duration ?? animationDuration
        lastUpdateTime = Date.timeIntervalSinceReferenceDate
        
        addDisplayLink()
    }
    
    func countFromCurrent(to: Float, duration: TimeInterval? = nil) {
        count(from: currentValue, to: to, duration: duration ?? nil)
    }
}

extension UIColor {
    class func getCustomLightBlueColor() -> UIColor{
        return UIColor(red:0.3961, green:0.7608 ,blue:1.0000 , alpha:1.00)
    }
    class func getCustomDarkBlueColor() -> UIColor{
        return UIColor(red:0.0784, green:0.3725 ,blue:0.5765 , alpha:1.00)
    }
    class func getCustomLightGrayColor() -> UIColor{
        return UIColor(red:0.9294, green:0.9333 ,blue:0.9333 , alpha:1.00)
    }
    class func getCustomDarkGreenColor() -> UIColor{
        return UIColor(red:0.2353, green:0.6863 ,blue:0.7529 , alpha:1.00)
    }
    class func getCustomDarkYellowColor() -> UIColor{
        return UIColor(red:0.8392, green:0.8196 ,blue:0.1765 , alpha:1.00)
    }
    class func getEurekaLightBlueColor() -> UIColor{
        return UIColor(red:0.5843, green:0.8039 ,blue:0.8510 , alpha:1.00)
    }
    class func getEurekaDarkBlueColor() -> UIColor{
        return UIColor(red:0.2275, green:0.6824 ,blue:0.7490 , alpha:1.00)
    }
    class func getEurekaDarkPurpleColor() -> UIColor{
        return UIColor(red:0.6196, green:0.3686 ,blue:0.5843 , alpha:1.00)
    }
    class func getEurekaDarkOrangeColor() -> UIColor{
        return UIColor(red:0.9098, green:0.7020 ,blue:0.4471 , alpha:1.00)
    }
    class func getEurekaLightGreenColor() -> UIColor{
        return UIColor(red:0.7451, green:0.8549 ,blue:0.8078 , alpha:1.00)
    }
    class func getFavoriteOrangeColor() -> UIColor{
        return UIColor(red:0.9922, green:0.6627 ,blue:0.5373 , alpha:1.00)
    }
    class func getBatteryDarkGreenColor() -> UIColor{
        return UIColor(red:14/255.0, green:162/255.0 ,blue:74/255.0 , alpha:1.00)
    }
    class func getBatteryDarkYellowColor() -> UIColor{
        return UIColor(red:238/255.0, green:199/255.0 ,blue:85/255.0 , alpha:1.00)
    }
    class func getBatteryDarkRedColor() -> UIColor{
        return UIColor(red:224/255.0, green:72/255.0 ,blue:75/255.0 , alpha:1.00)
    }
    
    class func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    class func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }

}

extension UIViewController {
    
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod5,1":
            return "iPod Touch 5"
        case "iPod7,1":
            return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4"
        case "iPhone4,1":
            return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":
            return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":
            return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s"
        case "iPhone7,2":
            return "iPhone 6"
        case "iPhone7,1":
            return "iPhone 6 Plus"
        case "iPhone8,1":
            return "iPhone 6s"
        case "iPhone8,2":
            return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air"
        case "iPad5,3", "iPad5,4":
            return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":
            return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":
            return "iPad Pro"
        case "AppleTV5,3":
            return "Apple TV"
        case "i386", "x86_64":
            return "Simulator"
        default:
            return identifier
        }
    }
}

extension UITabBar {
    
//    override open func sizeThatFits(_ size: CGSize) -> CGSize {
//        var sizeThatFits = super.sizeThatFits(size)
//        sizeThatFits.height = 73 // adjust your size here
//        return sizeThatFits
//    }
}

