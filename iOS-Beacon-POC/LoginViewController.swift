//
//  LoginViewController.swift
//  iOS-Beacon-POC
//
//  Created by Ernesto on 10/17/16.
//  Copyright © 2016 egomez. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class LoginViewController: UIViewController {
    
    @IBOutlet weak var dsiBox: UITextField!
    @IBOutlet weak var dsiSubmit: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var invalidLabel: UILabel!
    var key: String!
    var contentType: String!
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor.blackColor().CGColor, UIColor.darkGrayColor().CGColor]
        gradient.locations = [0.0, 0.85]
        self.view.layer.insertSublayer(gradient, atIndex: 0)

        key = "PYJIKS17nR1rjB+RroyU/KzgUmoz9x84r9YehdpLhJw="
        contentType = "application/json"
        
        invalidLabel.hidden = true
        
        view.addSubview(loginView)
        loginView.center = view.center
        view.layoutIfNeeded()
        dsiBox.addTarget(self, action: #selector(LoginViewController.didChangeTextView), forControlEvents: UIControlEvents.EditingChanged)
        self.disableDSIButton()
    }
    
    @IBAction func onDSISubmit(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "beaconAccessed")
        userID = dsiBox.text?.uppercaseString
        self.validateUser(userID!)
        self.dsiBox.text = ""
    }
    
    func didChangeTextView() {
        if (dsiBox.text == "") {
            self.disableDSIButton()
        } else {
            self.enableDSIButton()
        }
    }
    
    func disableDSIButton() {
        dsiSubmit.enabled = false
        dsiSubmit.alpha = 0.5
    }
    
    func enableDSIButton() {
        dsiSubmit.enabled = true
        dsiSubmit.alpha = 1
    }
    
    func validateUser(id: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ec2-52-44-53-47.compute-1.amazonaws.com:8080/DVG-CustomerEngagement-Services/api/customerengagement/user/" + id)!)
        request.HTTPMethod = "GET"
        request.addValue(key, forHTTPHeaderField: "authorization")
        request.addValue("D40234627", forHTTPHeaderField: "dsi")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error: \(error)")
                return
            }
            
            do {
                if let httpResponse = response as? NSHTTPURLResponse {
                    print("response status: \(httpResponse.statusCode) - validate user")
                }
                
                if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary{
                    var validDSI: Bool = false
                    if (result["first_name"] as? String) != nil {
                        validDSI = true
                    } else {
                        validDSI = false
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setDSIFlag(validDSI)
                    })
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func setDSIFlag(validDSI: Bool) {
        if (validDSI == true) {
            invalidLabel.hidden = true
            let loginFlag = true
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "dsi")
            NSUserDefaults.standardUserDefaults().setObject(loginFlag, forKey: "loginFlag")
            self.dismissViewControllerAnimated(true, completion: {})
        } else {
            invalidLabel.hidden = false
        }
    }


}
