//
//  AdditionalDetailViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/7/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class AdditionalDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var recentStudents: RecentStudents!
    var parseClient: ParseClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        recentStudents = RecentStudents.sharedInstance()
        parseClient = ParseClient.sharedInstance()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let studentsArray = recentStudents.getRecentStudents()
        
        if studentsArray.count == 0 {
            reloadStudentLocations()
        } else {
            // reload the table view
            tableView.reloadData()
        }
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
    
    // resets and gets the most recent 100 locations
    func reloadStudentLocations() {
        showBusy()
        // get top 100 students
        let parameters = [
            ParseClient.ParameterKeys.Limit: 100,
            ParseClient.ParameterKeys.Order : ParseClient.ParameterValues.CreatedAtDesc
        ]
        parseClient.getMostRecentStudentLocations(parameters as! [String : AnyObject]) { results, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNotBusy()
                    ApiHelper.displayErrorAlert(self, title: "Parse Error", message: "Error retrieving new data")
                }
            } else {
                if let results = results {
                    self.recentStudents.loadFromStudentArray(results)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
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
        let cellReuseIdentifier = "detailCell"
        let studentLocation = self.recentStudents.getRecentStudents()[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! AdditionalDetailTableViewCell
        
        // alternate the two gradient orange colors from the login page
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.717, blue: 0.419, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.498, blue: 0.016, alpha: 1.0)
        }
        
        cell.nameValueLabel.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.locationValueLabel.text = studentLocation.mapString
        cell.latitudeValueLabel.text = String(format: "%f", studentLocation.latitude)
        cell.longitudeValueLabel.text = String(format: "%f", studentLocation.longitude)

        return cell
    }
    
    // allow more than 100 students info to be loaded in a network effecient way by loading 10 more at a time when user
    // scrolls to the bottom of the list
    var firedViewLoad: Bool = false
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let currentStudentsCount = self.recentStudents.getRecentStudents().count
        let matchedIndex = currentStudentsCount - 1
        // check to prevent this from running every time they scroll. we expected 99 items on original load of data
        if !firedViewLoad && matchedIndex == indexPath.row && matchedIndex > 98 {
            firedViewLoad = true
            activityIndicator.startAnimating()
            let parameters = [
                ParseClient.ParameterKeys.Limit : 10,
                ParseClient.ParameterKeys.Skip : currentStudentsCount,
                ParseClient.ParameterKeys.Order : ParseClient.ParameterValues.CreatedAtDesc
            ]
            parseClient.getMostRecentStudentLocations(parameters as! [String : AnyObject]) { results, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        ApiHelper.displayErrorAlert(self, title: "Parse Error", message: "Error retrieving new data")
                    }
                } else {
                    if let result = results {
                        if result.count > 0 {
                            self.recentStudents.appendStudents(result)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                                self.activityIndicator.stopAnimating()
                                self.firedViewLoad = false
                            }
                        } else {
                            // no results
                            dispatch_async(dispatch_get_main_queue()) {
                                self.activityIndicator.stopAnimating()
                                // we have reached the end of the data set
                                // don't let the event fire any more (not setting firedViewLoad to false)
                            }
                        }
                    }
                }
            }
        }
    }
}
