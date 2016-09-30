//
//  ViewController.swift
//  iOS-Beacon-POC
//
//  Created by Ernesto on 9/28/16.
//  Copyright © 2016 egomez. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    @IBOutlet var welcomePopup: UIView!
    @IBOutlet var feedbackPopup: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var welcomeButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var thanksButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var metersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let device = UIDevice .currentDevice()
        print(device.name)
        print(device.model)
        print(device.identifierForVendor?.UUIDString)
        print(device.systemName)
        print(device.systemVersion)
        // Instantiate the location manager
        manager = CLLocationManager()
        // set delegate to self
        manager.delegate = self
        // if the permissions aren't set to track location - ask to always track
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestAlwaysAuthorization()
        }
        // set beacon region
        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "6fbbef7c-f92c-471e-8d5c-470e9b367fdb")!, identifier: "DeVry Meraki")
        // start ranging beacons
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // once permissions are accepted, start updating users location
        if status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // if no beacon is found, just exit the function
        if (beacons.count == 0) {
            return
        }
        
        let beacon: CLBeacon = beacons.first!
        var showWelcomePopup = false
        metersLabel.text = "Distance: " + String(Double(round(1000*beacon.accuracy)/1000)) + "m"
        
        // when the user is right next to the beacon, show welcome popup
        if (beacon.proximity == CLProximity.Immediate) {
            showWelcomePopup = true
        }
        
        if (showWelcomePopup) {
            manager.stopRangingBeaconsInRegion(beaconRegion)
            self.showWelcomePopup()
        }
    }
    
    func showWelcomePopup() {
        view.addSubview(welcomePopup)
        welcomePopup.center = view.center
        drawShadows(welcomePopup)
        view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onWelcomeButton(sender: AnyObject) {
        view.addSubview(welcomePopup)
        welcomePopup.center = view.center
        drawShadows(welcomePopup)
        view.layoutIfNeeded()
    }

    @IBAction func onFeedbackButton(sender: AnyObject) {
        view.addSubview(feedbackPopup)
        feedbackPopup.center = view.center
        drawShadows(feedbackPopup)
        view.layoutIfNeeded()
    }
    
    @IBAction func onThanksButton(sender: AnyObject) {
        self.welcomePopup.removeFromSuperview()
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    @IBAction func onSubmitButton(sender: AnyObject) {
        self.feedbackPopup.removeFromSuperview()
        ratingLabel.text = "Rating: " + String(ratingView.rating)
    }
    
    func drawShadows(viewToShadow: UIView) {
        viewToShadow.layer.shadowOpacity = 0.7
        viewToShadow.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewToShadow.layer.shadowRadius = 10.0
        viewToShadow.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
}

