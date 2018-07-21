//
//  Extensions .swift
//  Memer
//
//  Created by Nuri Chun on 5/3/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

extension UIColor
{
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor
    {
        return UIColor(displayP3Red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    static func mainDark() -> UIColor
    {
        return UIColor.rgb(r: 59, g: 56, b: 56)
    }
}

extension UIView
{
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, topPad: CGFloat, leftPad: CGFloat, bottomPad: CGFloat, rightPad: CGFloat, width: CGFloat, height: CGFloat)
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top
        {
            self.topAnchor.constraint(equalTo: top, constant: topPad).isActive = true
        }
        
        if let left = left
        {
            self.leftAnchor.constraint(equalTo: left, constant: leftPad).isActive = true
        }
        
        if let bottom = bottom
        {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomPad).isActive = true
        }
        
        if let right = right
        {
            self.rightAnchor.constraint(equalTo: right, constant: -rightPad).isActive = true
        }
        
        if width != 0
        {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0
        {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIViewController
{
    func hideKeyboardByTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}





