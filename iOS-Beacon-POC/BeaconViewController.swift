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
    
    var beaconUUID: String!
    var deviceID: String!
    var operatingSystem: String!
    var timeStamp: NSDate!
    var key: String!
    var dsi: String!
    var contentType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let device = UIDevice .currentDevice()
        deviceID = device.identifierForVendor?.UUIDString
        operatingSystem = device.systemName
        key = "PYJIKS17nR1rjB+RroyU/KzgUmoz9x84r9YehdpLhJw="
        dsi = "D40234627"
        contentType = "application/json"
        
        //Instantiate the location manager
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
        
        // when the user is near the beacon, show welcome popup
        if (beacon.proximity == CLProximity.Near) {
            showWelcomePopup = true
        }
        
        if (showWelcomePopup) {
            timeStamp = NSDate()
            manager.stopRangingBeaconsInRegion(beaconRegion)
            self.showWelcomePopup()
//            self.postJSON(beacon.proximityUUID.UUIDString)
            self.getCustomerEngagement()
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
    
    func getCustomerEngagement() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://mbldevapp1.dev.devry.edu:8080/DVG-CustomerEngagement-Services/api/customerengagement/")!)
        request.HTTPMethod = "GET"
        request.addValue(key, forHTTPHeaderField: "authorization")
        request.addValue(dsi, forHTTPHeaderField: "dsi")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            do {
                if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    print(result)
                    
                    let firstValue = result["Response"] as? String
                    print(firstValue)
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func generateJSON(UUID: String) -> [String: AnyObject] {
        let jsonObject: [String: AnyObject] = [
            "beaconUUID": UUID,
            "deviceID": deviceID,
            "operatingSystem": operatingSystem,
            "timeStamp": timeStamp
        ]
        print("json as string: =\(jsonObject)")
        return jsonObject
    }
    
    func generateServiceJSON() -> [String: AnyObject] {
        let jsonObject: [String: AnyObject] = [
            "caller_id": "D01317819",
            "contact_type": "Self-service",
            "short_description": "Short Test",
            "description": "Long Test"
        ]
        return jsonObject
    }
    
    func postJSON() {
        let json = generateServiceJSON()
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let url = NSURL(string: "http://mbldevapp1.dev.devry.edu:8080/DeVry-Mobile-Services/api/servicenow?sysparm_display_value=true")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.addValue(key, forHTTPHeaderField: "authorization")
            request.addValue(dsi, forHTTPHeaderField: "dsi")
            request.addValue(contentType, forHTTPHeaderField: "content-type")
            request.HTTPBody = jsonData
        
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
            
                if error != nil {
                    print("error=\(error)")
                    return
                }
            
                do {
                    if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        print(result)
                    
                    }
                }  catch {
                    print("Error=\(error)")
                }

            }
            task.resume()
        } catch {
            print(error)
        }
    }
    
}

