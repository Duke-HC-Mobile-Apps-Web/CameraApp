//
//  ViewController.swift
//  CameraApp
//
//  Created by Jesse Hu on 2/17/16.
//  Copyright © 2016 Jesse Hu. All rights reserved.
//

import UIKit
import CoreLocation

/* In order to set the location in the iOS Simulator before launchtime, instead of manually setting it after launching the app, follow the directions here: https://developer.apple.com/library/ios/recipes/xcode_help-scheme_editor/Articles/simulating_location_on_run.html */

/* Remember: You must add the proper key (NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription) in your Info.plist file for the location manager to work! Otherwise the app will not ask for permissions, and will not fetch location. 
  https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html
*/

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet var coordinateLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    // Initialize CLLocationManager object
    var locationManager = CLLocationManager()
    
    // Declare as an optional in case locationManager(_:didUpdateLocations) is never called
    var currentLocation: CLLocationCoordinate2D?
    
    /* This IBAction is connected to the UIBarButtonItem with the Camera icon on the bottom of the View Controller scene */
    @IBAction func cameraButtonPressed(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        
        // If the Camera is not available, default to Photo Library
        // The iOS Simulator does not support Camera
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        // Make sure to set the delegate in order to receive method calls
        // Must conform to both UINavigationControllerDelegate and UIImagePickerControllerDelegate
        imagePicker.delegate = self
        
        // Transition to our UIImagePickerController (a view controller) using a method call instead of a segue
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerController delegate
    
    /* This is called after the user takes/chooses a photo. */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Set the image of our imageView (simple!)
        imageView.image = image
        // Transition back from our UIImagePickerController (a view controller) using a method call instead of a segue
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up our CLLocation parameter(s)
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // CLLocationManagerDelegate
        locationManager.delegate = self
        // Must request permission. Alternative is requestAlwaysAuthorization, which can monitor in background.
        locationManager.requestWhenInUseAuthorization()
        // Start updating location
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManager delegate

    /* Called when new location is available, within the accuracy specified before. The parameter locations is an array, whose last CLLocation object is the most recent. */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            if let location = locations.last {
                currentLocation = location.coordinate
                if let lat = currentLocation?.latitude, long = currentLocation?.longitude {
                    coordinateLabel.text = NSString(format: "(%.1f, %.1f)", lat, long) as String
                }
                
            }
        }
    }
    
    /* Another delegate method, which is called when the location manager fails */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed. Error: \(error.domain)")
    }
    
    /* Called before any segue from ViewController (this class) */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapSegue" {
            // Must cast the destinationViewController (the scene we are segueing to) to the proper class in order to access its properties
            if let mapVC = segue.destinationViewController as? MapViewController {
                mapVC.location = currentLocation
            }
        }
    }


}

