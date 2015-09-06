//
//  LocationDetailViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/5/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var locationTableView: UITableView!
    var mostRecentStudentLocations: [StudentInformation] = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinNewLocationTouchUp")
        pinButton.tintColor = UIColor.blueColor()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadStudentLocations")
        refreshButton.tintColor = UIColor.blueColor()
        
        var rightButtons = [UIBarButtonItem]()
        rightButtons.append(refreshButton)
        rightButtons.append(pinButton)
        self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonTouchUp")
        self.navigationItem.title = "On The Map"

        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = UIColor.whiteColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadStudentLocations()
    }
    
    func showBusy() {
        activityIndicator.startAnimating()
        self.view.alpha = 0.6
    }
    
    func showNotBusy() {
        activityIndicator.stopAnimating()
        self.view.alpha = 1.0
    }
    
    func reloadStudentLocations() {
        showBusy()
        let parseClient = ParseClient.sharedInstance()
        parseClient.getMostRecentStudentLocations() { results, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNotBusy()
                    ApiHelper.displayErrorAlert(self, title: "Parse Error", message: "Error retrieving new data")
                }
            } else {
                if let results = results {
                    self.mostRecentStudentLocations = results
                    dispatch_async(dispatch_get_main_queue()) {
                        self.locationTableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.view.alpha = 1.0
                    }
                }
            }
        }
    }
    
    func pinNewLocationTouchUp() {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mostRecentStudentLocations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "LocationDetailCell"
        let studentLocation = mostRecentStudentLocations[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        // set the cell
        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.imageView!.image = UIImage(named: "pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let studentLocation = mostRecentStudentLocations[indexPath.row]
        let urlString = studentLocation.mediaUrl
        app.openURL(NSURL(string: studentLocation.mediaUrl)!)
    }

}
