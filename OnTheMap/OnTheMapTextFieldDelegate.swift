//
//  OnTheMapTextFieldDelegate.swift
//  OnTheMap
//
//  Created by James Tench on 9/7/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit

class OnTheMapTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}
