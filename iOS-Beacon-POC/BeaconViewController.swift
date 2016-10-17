//
//  ViewController.swift
//  iOS-Beacon-POC
//
//  Created by Ernesto on 9/28/16.
//  Copyright © 2016 egomez. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AVFoundation
import FirebaseMessaging

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    var manager: CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    var beaconRegion2 : CLBeaconRegion!
    var bluetoothManager : CBCentralManager!
    @IBOutlet var welcomePopup: UIView!
    @IBOutlet var feedbackPopup: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var thanksButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var metersLabel: UILabel!
    
    var beaconUUID: String!
    var deviceID: String!
    var operatingSystem: String!
    var timeStamp: NSDate!
    var key: String!
    var dsi: String!
    var contentType: String!
    var showWelcomePopup = false
    var showFeedbackPopup = false
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // check bluetooth settings
        bluetoothManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        self.centralManagerDidUpdateState(bluetoothManager)
        
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
        
//        FIRMessaging.messaging().subscribeToTopic("/topics/feedback")
    }
    
    override func viewDidAppear(animated: Bool) {
        let hasLogin = NSUserDefaults.standardUserDefaults().objectForKey("loginFlag") as? Bool
        if (hasLogin == true) {
            userID = String(NSUserDefaults.standardUserDefaults().objectForKey("dsi"))
            print(userID)
            self.startMonitoring()
        } else {
            performSegueWithIdentifier("Show Login", sender: nil)
        }
    }
    
    func startMonitoring() {
        print("Monitoring Started")
        // set beacon region
        //        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "6fbbef7c-f92c-471e-8d5c-470e9b367fdb")!, major: 0, minor: 1, identifier: "Mobile Area")
        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "DeVry Commons")
        
        // start ranging beacons
        manager.stopRangingBeaconsInRegion(beaconRegion)
        manager.startMonitoringForRegion(beaconRegion)
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(bluetoothManager.state) {
        case CBCentralManagerState.PoweredOff:
            let alert = UIAlertView.init(title: "Bluetooth Settings", message: "Please enable Bluetooth on your device for this application to work", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        default:
            print("unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // once permissions are accepted, start updating users location
        if status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeaconsInRegion(beaconRegion)
        let welcomeFlag = NSUserDefaults.standardUserDefaults().objectForKey("welcomeFlag") as? Bool
        if (welcomeFlag == true) {
            let feedbackFlag = NSUserDefaults.standardUserDefaults().objectForKey("feedbackFlag") as? Bool
            if (feedbackFlag == true) {
                showFeedbackPopup = false
            } else {
                showFeedbackPopup = true
            }
        }
        
        if (showFeedbackPopup) {
            self.showPopUp(feedbackPopup)
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // if no beacon is found, just exit the function
        if (beacons.count == 0) {
            return
        }
                
        let beacon: CLBeacon = beacons.first!
        metersLabel.text = "Distance: " + String(Double(round(1000*beacon.accuracy)/1000)) + "m - " + String(region.identifier) + " - UUID: " + String(beacon.proximityUUID) + "- MAJ: " + String(beacon.major) + "- MIN: " + String(beacon.minor)
        // when the user is near the beacon (5meters or less), show welcome popup
        let distance = Double(round(1000*beacon.accuracy)/1000)
        let welcomeFlag = NSUserDefaults.standardUserDefaults().objectForKey("welcomeFlag") as? Bool
        if (distance <= 5.0 && beacon.proximity != CLProximity.Unknown) {
            if (welcomeFlag == true) {
                showWelcomePopup = false
            } else {
                showWelcomePopup = true
            }
        }
        
        if (welcomeFlag == true && distance >= 10.0 && beacon.proximity != CLProximity.Unknown) {
            let feedbackFlag = NSUserDefaults.standardUserDefaults().objectForKey("feedbackFlag") as? Bool
            if (feedbackFlag == true) {
                showFeedbackPopup = false
            } else {
                showFeedbackPopup = true
            }
        }
        
        if (showWelcomePopup) {
            timeStamp = NSDate()
            manager.stopRangingBeaconsInRegion(beaconRegion)
            self.showPopUp(welcomePopup)
            //in background mode, show notification so user is prompted to open app
            let appState = UIApplication.sharedApplication().applicationState
            if (appState == .Background) {
                self.alertUser("DVG IT would like to welcome you.")
            }
            self.postUserInformation(beacon.proximityUUID.UUIDString)
        }
        
        if (showFeedbackPopup) {
            manager.stopRangingBeaconsInRegion(beaconRegion)
            self.showPopUp(feedbackPopup)
            //in background mode, show notification so user is prompted to open app
            let appState = UIApplication.sharedApplication().applicationState
            if (appState == .Background) {
                self.alertUser("DVG IT is requesting feedback.")
            }
        }
    }
    
    func showPopUp(popup: UIView) {
        let notificationSound = SystemSoundID(1015)
        AudioServicesPlaySystemSound(notificationSound)
        view.addSubview(popup)
        popup.center = view.center
        drawShadows(popup)
        view.layoutIfNeeded()
    }
    
    func alertUser(message: String) {
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onThanksButton(sender: AnyObject) {
        showWelcomePopup = false
        let setWelcomeFlag = true
        NSUserDefaults.standardUserDefaults().setObject(setWelcomeFlag, forKey: "welcomeFlag")
        self.welcomePopup.removeFromSuperview()
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    @IBAction func onSubmitButton(sender: AnyObject) {
        showFeedbackPopup = false
        let setFeedbackFlag = true
        NSUserDefaults.standardUserDefaults().setObject(setFeedbackFlag, forKey: "feedbackFlag")
        self.feedbackPopup.removeFromSuperview()
        manager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func drawShadows(viewToShadow: UIView) {
        viewToShadow.layer.shadowOpacity = 0.7
        viewToShadow.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewToShadow.layer.shadowRadius = 10.0
        viewToShadow.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    func getAttendeeList() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://mblpocapp1.poc.devry.edu:9000/attendees")!)
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
                if let httpResponse = response as? NSHTTPURLResponse {
                    print("responseStatus = \(httpResponse.statusCode)")
                }
                
                if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSArray {
                    print(result)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func generateWelcomeJSON(UUID: String) -> [String: AnyObject] {
        let jsonObject: [String: AnyObject] = [
            "deviceID": deviceID,
            "beaconID": UUID,
            "os": operatingSystem,
            "timestamp": String(timeStamp),
            "userID": userID
        ]
        return jsonObject
    }
    
    func generateFeedbackJSON() -> [String: AnyObject] {
        let jsonObject: [String: AnyObject] = [
            "rating": ratingView.rating,
            "comments": commentBox.text!
        ]
        return jsonObject
    }
    
    func postUserInformation(UUID: String) {
        let json = generateWelcomeJSON(UUID)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let url = NSURL(string: "http://ec2-52-44-53-47.compute-1.amazonaws.com:8080/DVG-CustomerEngagement-Services/api/customerengagement/registerAttendee")
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
                    if let httpResponse = response as? NSHTTPURLResponse {
                        print("responseStatus = \(httpResponse.statusCode)")
                    }
                    if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary {
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

