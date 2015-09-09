//
//  MapViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/2/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // we expect this to be attached when the view controller is launched
    var udacityStudent : UdacityStudent!
    
    // will fill the array from the StudentInformation that is stored in external object
    var recentStudents: RecentStudents!

    override func viewDidLoad() {
        super.viewDidLoad()
        udacityStudent = UdacityClient.sharedInstance().udacityStudent!
        recentStudents = RecentStudents.sharedInstance()
        self.mapView.delegate = self
        
        // navigation buttons
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
        
        // set properties for progress wheel
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // check if the array of Students has been filled, if so use that to build
        // the array so we are not making extra network calls
        // else if no data, then reload it
        let studentsArray = recentStudents.getRecentStudents()
        
        if studentsArray.count == 0 {
            reloadStudentLocations()
        } else {
            // clear any current pins
            self.mapView.removeAnnotations(annotations)
            addAnnotationsFromStudentArray(studentsArray)
            // put new pins back on the map
            mapView.addAnnotations(self.annotations)
        }
    }
    
    func pinNewLocationTouchUp() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("postLocationController") as! PostLocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
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
        let parameters = [
            ParseClient.ParameterKeys.Limit: 100,
            ParseClient.ParameterKeys.Order : ParseClient.ParameterValues.UpdatedAtDesc
        ]
        parseClient.getMostRecentStudentLocations(parameters as! [String : AnyObject]) { results, error in
            if let error = error {
                // show custom message - error will contain difference between parsing error or network error
                var customError: String
                if let message = ApiHelper.errorForNSError(error) {
                    customError = message
                } else {
                    customError = "Error getting most recent students"
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNotBusy()
                    ApiHelper.displayErrorAlert(self, title: "Parse Error", message: customError)
                }
            } else {
                if let results = results {
                    // keep shared object up to date
                    self.recentStudents.loadFromStudentArray(results)
                    // clear prior annotations with the current array values
                    self.mapView.removeAnnotations(self.annotations)
                    self.addAnnotationsFromStudentArray(results)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.addAnnotations(self.annotations)
                        self.showNotBusy()
                    }
                }
            }
        }
    }
    
    func addAnnotationsFromStudentArray(students: [StudentInformation]) {
        for student in students {
            let lat = CLLocationDegrees(student.latitude as Double)
            let lon = CLLocationDegrees(student.longitude as Double)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaUrl
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            self.annotations.append(annotation)
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation.subtitle!)!)
        }
    }
}