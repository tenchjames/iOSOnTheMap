//
//  MapViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/2/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // we expect this to be attached when the view controller is launched
    var udacityStudent : UdacityStudent!

    override func viewDidLoad() {
        super.viewDidLoad()
        udacityStudent = UdacityClient.sharedInstance().udacityStudent!
        // Do any additional setup after loading the view.
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
        reloadStudentLocations()
    }
    
    func pinNewLocationTouchUp() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("postLocationController") as! PostLocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logoutButtonTouchUp() {
        
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
        var mostRecentStudentLocations: [StudentInformation] = [StudentInformation]()
        parseClient.getMostRecentStudentLocations() { results, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showNotBusy()
                    ApiHelper.displayErrorAlert(self, title: "Parse Error", message: "Error retrieving new data")
                }
            } else {
                if let results = results {
                    // clear prior annotations with the current array values
                    self.mapView.removeAnnotations(self.annotations)
                    self.annotations = [MKPointAnnotation]()
                    for result in results {
                        let lat = CLLocationDegrees(result.latitude as Double)
                        let lon = CLLocationDegrees(result.longitude as Double)
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let first = result.firstName
                        let last = result.lastName
                        let mediaURL = result.mediaUrl
                        
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        self.annotations.append(annotation)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.addAnnotations(self.annotations)
                        self.showNotBusy()
                    }
                }
            }
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
































