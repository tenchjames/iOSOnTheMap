//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/5/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var previewURLButton: UIButton!
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewWhereLabel: UILabel!
    @IBOutlet weak var topViewStudyLabel: UILabel!
    @IBOutlet weak var topViewTodayLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    
    var udacityStudent: UdacityStudent!
    var parseClient: ParseClient!
    var newLatitude: CLLocationDegrees?
    var newLongitude: CLLocationDegrees?
    let urlTextFieldDelegate = URLTextFieldDelegate()
    var tapRecognizer: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        udacityStudent = UdacityClient.sharedInstance().udacityStudent
        parseClient = ParseClient.sharedInstance()
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.urlTextField.delegate = urlTextFieldDelegate
        locationSearchTextField.delegate = self
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        showFindView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        configureView()
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func configureView() {
        submitButton.layer.cornerRadius = 4.0
        findButton.layer.cornerRadius = 4.0
    }
    
    func showFindView() {
        bottomView.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1.0)
        topView.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1.0)
        
        locationSearchTextField.enabled = true
        locationSearchTextField.hidden = false
        
        findButton.enabled = true
        findButton.hidden = false
        
        submitButton.hidden = true
        submitButton.enabled = false
        
        topViewWhereLabel.hidden = false
        topViewTodayLabel.hidden = false
        topViewStudyLabel.hidden = false
        
        urlTextField.hidden = true
        urlTextField.enabled = false
        
        previewURLButton.hidden = true
        previewURLButton.enabled = false
        
        mapView.hidden = true
    }
    
    func hideFindView() {
        // TODO: figure how to make bottom view opaque so more of the map shows??
        bottomView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        topView.backgroundColor = UIColor(red: 0.553, green: 0.718, blue: 1.0, alpha: 1.0)
        
        locationSearchTextField.enabled = false
        locationSearchTextField.hidden = true
        
        findButton.enabled = false
        findButton.hidden = true
        
        submitButton.hidden = false
        submitButton.enabled = true
        submitButton.alpha = 1.0
        
        topViewWhereLabel.hidden = true
        topViewTodayLabel.hidden = true
        topViewStudyLabel.hidden = true
        
        urlTextField.hidden = false
        urlTextField.enabled = true
        
        previewURLButton.hidden = false
        previewURLButton.enabled = true
        
        mapView.hidden = false
    }
    
    func searchForLocation() {
        // remove any pins on the map from prior search
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        
        // using the CLGeocoder class
        let geoCoding = CLGeocoder()
        activityMonitor.startAnimating()
        geoCoding.geocodeAddressString(locationSearchTextField.text) { placeMarks, error in
            self.activityMonitor.stopAnimating()
            var message: String
            if let error = error {
                let code = error.code
                
                if code == CLError.Network.rawValue {
                    message = "Please check your internet connection"
                } else if code == CLError.GeocodeFoundNoResult.rawValue {
                    message = "Unable to find that location"
                } else if code == CLError.GeocodeCanceled.rawValue {
                    message = "Search canceled"
                } else {
                    // handle other errors with general message
                    message = "Unable to search at this time"
                }
                ApiHelper.displayErrorAlert(self, title: "Geo Coding Error", message: message)
            } else {
                // grab the first location returned
                if placeMarks.count > 0 {
                    let placeMark = placeMarks[0] as! CLPlacemark
                    if let location = placeMark.location {
                        let coordinate = location.coordinate
                        self.newLatitude = coordinate.latitude
                        self.newLongitude = coordinate.longitude
                        
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = self.locationSearchTextField.text
                        
                        let span = MKCoordinateSpanMake(0.05, 0.05)
                        let region = MKCoordinateRegionMake(coordinate, span)
                        self.mapView.region = region
                        self.mapView.centerCoordinate = coordinate
                        self.mapView.addAnnotation(annotation)
                        
                        self.hideFindView()
                    } else {
                        // none found or error because no location was loaded
                        ApiHelper.displayErrorAlert(self, title: "Location search error", message: "Unable to find that location at this time")
                    }
                } else {
                    // none found
                    ApiHelper.displayErrorAlert(self, title: "Location not found", message: "Unable to find that location, please search again")
                }
            }
        }
    }
    
    @IBAction func previewURLTouchUp() {
        if urlTextField.text.isEmpty || !ApiHelper.isValidURL(urlTextField.text) {
            ApiHelper.displayErrorAlert(self, title: "Unable to preview URL", message: "Enter a url in the form http(s)://")
        } else {
            
            let authorizationURL = NSURL(string: urlTextField.text)
            let request = NSURLRequest(URL: authorizationURL!)
            let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("URLPreviewViewController") as! URLPreviewViewController
            webViewController.urlRequest = request
            
            let webNavigationController = UINavigationController()
            webNavigationController.pushViewController(webViewController, animated: false)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(webNavigationController, animated: true, completion: nil)
            })
        }
        
    }
    @IBAction func submitNewLocation() {
        if urlTextField.text.isEmpty || !ApiHelper.isValidURL(urlTextField.text) {
            ApiHelper.displayErrorAlert(self, title: "Invalid URL", message: "Enter a url in the form http(s)://")
        } else {
            let studentParameters: [String: AnyObject] = [
                ParseClient.JSONResponseKeys.UniqueKey : udacityStudent.emailAddress!,
                ParseClient.JSONResponseKeys.FirstName : udacityStudent.firstName!,
                ParseClient.JSONResponseKeys.LastName : udacityStudent.lastName!,
                ParseClient.JSONResponseKeys.MapString : locationSearchTextField.text,
                ParseClient.JSONResponseKeys.MediaURL : urlTextField.text,
                ParseClient.JSONResponseKeys.Latitude : newLatitude!,
                ParseClient.JSONResponseKeys.Longitude : newLongitude!
            ]
            let newStudent = StudentInformation(dictionary: studentParameters)
            
            parseClient.postNewStudentLocation(newStudent) { result, error in
                if let error = error {
                    let errorString = ApiHelper.errorForNSError(error)
                    dispatch_async(dispatch_get_main_queue()) {
                        if errorString != nil {
                            ApiHelper.displayErrorAlert(self, title: "Location search error", message: errorString!)
                        } else {
                            ApiHelper.displayErrorAlert(self, title: "Location search error", message: "Unable to post location")
                        }
                    }
                } else {
                    // insert us at the top of the stack so view see newly added without having to reload
                    RecentStudents.sharedInstance().prependStudent(newStudent)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTouchUp() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findLocationOnMap() {
        // validate that text is entered into the field
        if locationSearchTextField.text.isEmpty {
            ApiHelper.displayErrorAlert(self, title: "Missing Location", message: "You must enter a location")
        } else {
            searchForLocation()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
