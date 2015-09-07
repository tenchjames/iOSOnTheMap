//
//  LocationDetailViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/5/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LocationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationTableView: UITableView!
    // will fill the array from the StudentInformation that is stored in external object
    var recentStudents: RecentStudents!
    var parseClient: ParseClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recentStudents = RecentStudents.sharedInstance()
        parseClient = ParseClient.sharedInstance()
        
        // top nav bar buttons
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
        self.view.alpha = 0.8
    }
    
    func showNotBusy() {
        activityIndicator.stopAnimating()
        self.view.alpha = 1.0
    }
    
    func logoutButtonTouchUp() {
        let udacity = UdacityClient.sharedInstance()
        let facebookStatus = udacity.facebookLogin
        
        if facebookStatus {
            var logout: FBSDKLoginManager = FBSDKLoginManager()
            logout.logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            UdacityClient.sharedInstance().deleteUdacitySession() { result, error in
                if let error = error {
                    // how to handle error on delete??? hmm
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }
    
    func pinNewLocationTouchUp() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("postLocationController") as! PostLocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func reloadStudentLocations() {
        showBusy()
        // get top 100 students
        let parameters = [
            ParseClient.ParameterKeys.Limit: 100
        ]
        parseClient.getMostRecentStudentLocations(parameters) { results, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNotBusy()
                    ApiHelper.displayErrorAlert(self, title: "Parse Error", message: "Error retrieving new data")
                }
            } else {
                if let results = results {
                    self.recentStudents.loadFromStudentArray(results)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.locationTableView.reloadData()
                        self.showNotBusy()
                        self.view.alpha = 1.0
                    }
                }
            }
        }
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentStudents.getRecentStudents().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "LocationDetailCell"
        let studentLocation = self.recentStudents.getRecentStudents()[indexPath.row]
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
        let studentLocation = self.recentStudents.getRecentStudents()[indexPath.row]
        let urlString = studentLocation.mediaUrl
        app.openURL(NSURL(string: studentLocation.mediaUrl)!)
    }
    
    // allow more than 100 students info to be loaded in a network effecient way by loading 10 more at a time when user
    // scrolls to the bottom of the list
    var firedViewLoad: Bool = false
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let currentStudentsCount = self.recentStudents.getRecentStudents().count
        let matchedIndex = currentStudentsCount - 1
        if !firedViewLoad && matchedIndex == indexPath.row {
            firedViewLoad = true
            
            let parameters = [
                ParseClient.ParameterKeys.Limit : 10,
                ParseClient.ParameterKeys.Skip : currentStudentsCount
            ]
            parseClient.getMostRecentStudentLocations(parameters) { results, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showNotBusy()
                        ApiHelper.displayErrorAlert(self, title: "Parse Error", message: "Error retrieving new data")
                    }
                } else {
                    if let results = results {
                        self.recentStudents.appendStudents(results)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.locationTableView.reloadData()
                            self.firedViewLoad = false
                        }
                    }
                }
            }
        }
    }
}
