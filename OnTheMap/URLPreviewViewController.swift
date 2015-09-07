//
//  URLPreviewViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/7/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit

class URLPreviewViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!

    var urlRequest: NSURLRequest? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "URL Preview"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "returnToOnTheMap")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest!)
        }
    }

    func returnToOnTheMap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
