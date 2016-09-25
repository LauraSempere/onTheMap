//
//  SendInformationViewController.swift
//  OnTheMap
//
//  Created by Laura Scully on 24/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit
import MapKit

class SendInformationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var submitLocationView:UIStackView!
    @IBOutlet weak var submitMediaURLView:UIStackView!
    
    @IBOutlet weak var locationTextField:UITextField!
    @IBOutlet weak var parseLocationStringButton:UIButton!
    
    @IBOutlet weak var mediaURLTextField:UITextField!
    @IBOutlet weak var submitLocationButton:UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let alert = Alert()
    let parseClient = ParseClient.sharedInstance()
    // let udacityClient = UdacityClient.sharedInstance()
    var currentStudent = UdacityClient.sharedInstance().currentStudent
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
        locationTextField.clearsOnBeginEditing = true
        mediaURLTextField.clearsOnBeginEditing = true
        
        activityIndicatorView.hidden = true
        submitLocationView.hidden = false
        submitMediaURLView.hidden = true

        locationTextField.backgroundColor = UIColor.blueColor()
        mediaURLTextField.backgroundColor = UIColor.blueColor()
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func toggleActivityIndicator(loading: Bool){
        if loading {
            activityIndicatorView.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicatorView.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func parseLocationString(sender: AnyObject) {
        let location = CLGeocoder()
        self.toggleActivityIndicator(true)
        location.geocodeAddressString(locationTextField.text!) { (placemark: [CLPlacemark]?, error: NSError?) in
            if let err = error {
                print("Error: \(err)")
                self.toggleActivityIndicator(false)
                self.alert.show(self, title:"Error Getting your Location", message: "Please provide a correct address, city or country", actionText: "Dismiss", additionalAction: nil)
            } else {
                if let location = placemark!.last?.location {
                    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
                    
                    self.mapView.setRegion(region, animated: true)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = self.locationTextField.text!
                    self.mapView.addAnnotation(annotation)
                    
                    self.submitMediaURLView.hidden = false
                    self.submitLocationView.hidden = true
                    self.toggleActivityIndicator(false)
                    
                    self.currentStudent.latitude = location.coordinate.latitude as! Double
                    self.currentStudent.longitude = location.coordinate.longitude as! Double
                    self.currentStudent.mapString = self.locationTextField.text!
                    
                    print("Current Student:: \(self.currentStudent)")
                
                } else {
                    print("No location found")
                    self.alert.show(self, title: "No location found", message: "Could not find your location. Please try again", actionText: "Dismiss", additionalAction:   nil)
                    self.toggleActivityIndicator(false)
                }
                
            }
        }
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func submitLocationInformation(sender: AnyObject) {
        if let mediaURL = mediaURLTextField.text {
            let userInfo:[String: AnyObject] = ["uniqueKey": currentStudent.uniqueKey, "firstName": "Laura", "lastName": "Sempere", "mapString" : currentStudent.mapString, "mediaURL": mediaURL, "latitude":currentStudent.latitude, "longitude": currentStudent.longitude]
            
            parseClient.sendStudentInfo(userInfo, completionHandlerForSendingInfo: { (success, errorString) in
                if success {
                    print("Post Student Info Succeded")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    self.alert.show(self, title: "Error sending information", message: errorString!, actionText: "Dismiss", additionalAction: nil)
                }
                
            })
            
        }
    }

}
