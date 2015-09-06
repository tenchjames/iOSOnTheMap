//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by James Tench on 9/5/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        configureView()
    }
    
    
    func configureView() {
        mapView.hidden = true
        submitButton.hidden = true
        submitButton.enabled = false
        
    }
    
    func hideFindView() {
        locationSearchTextField.enabled = false
        locationSearchTextField.hidden = true
        findButton.enabled = false
        findButton.hidden = true
        submitButton.hidden = false
        submitButton.enabled = true
        
        // TODO: figure how to make bottom view opaque so more of the map shows??
//        bottomView.backgroundColor = UIColor.whiteColor()
//        bottomView.alpha = 0.25
//        bottomView.opaque = true
//        submitButton.alpha = 1.0
        
        mapView.hidden = false
        
    }
    
    
    func searchForLocation() {
        // remove any pins on the map from prior search
        
        // do a location search based on text
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationSearchTextField.text
        
        
        // handle ui update with call back, or alert that location was not found
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTouchUp() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findLocationOnMap() {
        hideFindView()
    }
    
    
    @IBOutlet weak var submitLocation: UIButton!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
