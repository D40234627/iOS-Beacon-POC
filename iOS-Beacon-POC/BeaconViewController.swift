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
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    var manager: CLLocationManager!
//    var beaconRegion : CLBeaconRegion!
    var beaconRegion2 : CLBeaconRegion!
    var bluetoothManager : CBCentralManager!
    @IBOutlet var welcomePopup: UIView!
    @IBOutlet var feedbackPopup: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var commentBox: UITextField!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var thanksButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var metersLabel: UILabel!
    
    var beaconUUID: String!
    var deviceID: String!
    var operatingSystem: String!
    var timeStamp: String!
    var key: String!
    var dsi: String!
    var contentType: String!
    var showWelcomePopup = false
    var showFeedbackPopup = false
    var userID: String!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var beaconList: NSArray = []
    
    let dateFormatter = NSDateFormatter()

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkFeedback", name: "feedbackNotification", object: nil)
        
    }
    
    func checkFeedback() {
        let question = appDelegate.questionNumber
        print("THE QUESTION: \(question)")
        
//        manager.stopRangingBeaconsInRegion(beaconRegion)
        questionText.text = appDelegate.questionText
        self.showPopUp(feedbackPopup)
        //in background mode, show notification so user is prompted to open app
        let appState = UIApplication.sharedApplication().applicationState
        if (appState == .Background) {
            self.alertUser("DVG IT is requesting feedback.")
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        let hasLogin = NSUserDefaults.standardUserDefaults().objectForKey("loginFlag") as? Bool
        if (hasLogin == true) {
             // if the permissions aren't set to track location - ask to always track
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                manager.requestAlwaysAuthorization()
            }
            userID = NSUserDefaults.standardUserDefaults().objectForKey("dsi") as! String
            print(userID)
            self.getBeacons()
        } else {
            performSegueWithIdentifier("Show Login", sender: nil)
        }
    }
    
    func operateBeacons(operation: String) {
        print("Operate Beacons")
        
        for beacon in (beaconList as NSArray) {
            let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: beacon["beacon_id"] as! String)!, identifier: beacon["room_name"] as! String)
            switch(operation) {
            case "stop range":
                manager.stopRangingBeaconsInRegion(beaconRegion)
                break
            case "start range":
                manager.startRangingBeaconsInRegion(beaconRegion)
                break
            case "stop monitoring":
                manager.stopMonitoringForRegion(beaconRegion)
                break
            case "start monitoring":
                manager.startRangingBeaconsInRegion(beaconRegion)
                break
            case "all":
                manager.stopRangingBeaconsInRegion(beaconRegion)
                manager.startMonitoringForRegion(beaconRegion)
                manager.startRangingBeaconsInRegion(beaconRegion)
                break
            default:
                break
            }
        }
        //        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "6fbbef7c-f92c-471e-8d5c-470e9b367fdb")!, major: 0, minor: 1, identifier: "Mobile Area")
//        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "DeVry Commons")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(bluetoothManager.state) {
        case CBCentralManagerState.PoweredOff:
            let alert = UIAlertView.init(title: "Bluetooth Settings", message: "Please enable Bluetooth on your device for this application to work", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        default:
            print(" ")
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // once permissions are accepted, start updating users location
        if status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.operateBeacons("start range")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.operateBeacons("stop range")
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
        
        if (showWelcomePopup) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            timeStamp = dateFormatter.stringFromDate(NSDate())
            self.operateBeacons("stop range")
            self.showPopUp(welcomePopup)
            //in background mode, show notification so user is prompted to open app
            let appState = UIApplication.sharedApplication().applicationState
            if (appState == .Background) {
                self.alertUser("DVG IT would like to welcome you.")
            }
            self.checkInUser(beacon.proximityUUID.UUIDString, room: region.identifier)
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
        self.operateBeacons("stop monitoring")
    }
    
    @IBAction func onSubmitButton(sender: AnyObject) {
        self.postUserFeedback()
        self.feedbackPopup.removeFromSuperview()
    }
    
    func drawShadows(viewToShadow: UIView) {
        viewToShadow.layer.shadowOpacity = 0.7
        viewToShadow.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewToShadow.layer.shadowRadius = 10.0
        viewToShadow.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    func getBeacons() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ec2-52-44-53-47.compute-1.amazonaws.com:8080/DVG-CustomerEngagement-Services/api/customerengagement/beacon_location")!)
        request.HTTPMethod = "GET"
        request.addValue(key, forHTTPHeaderField: "authorization")
        request.addValue(dsi, forHTTPHeaderField: "dsi")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error: \(error)")
                return
            }
            
            do {
                if let httpResponse = response as? NSHTTPURLResponse {
                    print("response status: \(httpResponse.statusCode) - get beacons")
                }
                
                if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSArray {
                    self.beaconList = result
                    self.operateBeacons("all")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func generateWelcomeJSON(UUID: String, room: String) -> [String: AnyObject] {
        let jsonObject: [String: AnyObject] = [
            "attendeeID": userID,
            "beaconID": UUID,
            "eventID": "1",
            "eventName": "IT All Hands Meeting",
            "timestamp": timeStamp,
            "os": operatingSystem,
            "deviceID": deviceID
        ]
        return jsonObject
    }
    
    func generateFeedbackJSON() -> [String: AnyObject] {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let jsonObject: [String: AnyObject] = [
            "attendee_id": userID,
            "event_id": "1",
            "question_id": appDelegate.questionNumber as String,
            "question_text": appDelegate.questionText as String,
            "event_name": "IT All Hands Meeting",
            "rating_amount": ratingView.rating,
            "rating_comment": commentBox.text!,
            "rating_date": dateFormatter.stringFromDate(NSDate())
        ]
        return jsonObject
    }
    
    func checkInUser(UUID: String, room: String) {
        let json = generateWelcomeJSON(UUID, room: room)
        print(json)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let url = NSURL(string: "http://ec2-52-44-53-47.compute-1.amazonaws.com:8080/DVG-CustomerEngagement-Services/api/customerengagement/attendance")
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
                        print("responseStatus = \(httpResponse.statusCode) - checkInUser")
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
    
    func postUserFeedback() {
        let json = generateFeedbackJSON()
        print(json)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let url = NSURL(string: "http://ec2-52-44-53-47.compute-1.amazonaws.com:9000/DVG-CustomerEngagement-Services/api/customerengagement/ratings_by_question_and_user")
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
                        print("responseStatus = \(httpResponse.statusCode) - postfeedback")
                    }
                    if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary {
                        print(result)
                    }
                } catch {
                    print("Error=\(error)")
                }
            }
            task.resume()
        } catch {
            print(error)
        }
    }
    
}

