//
//  URLTextFieldDelegate.swift
//  OnTheMap
//
//  Created by James Tench on 9/7/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit

class URLTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        if !ApiHelper.isValidURL(newText as String) {
            textField.textColor = UIColor.redColor()
            textField.text = newText as String
            return false
        }
        
        textField.textColor = UIColor.whiteColor()
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
