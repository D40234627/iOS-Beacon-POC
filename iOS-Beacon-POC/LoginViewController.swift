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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginView)
        loginView.center = view.center
        view.layoutIfNeeded()
        dsiBox.addTarget(self, action: #selector(LoginViewController.didChangeTextView), forControlEvents: UIControlEvents.EditingChanged)
        self.disableDSIButton()
    }
    
    @IBAction func onDSISubmit(sender: AnyObject) {
        FIRMessaging.messaging().subscribeToTopic("/topics/feedback")
        let dsi = dsiBox.text
        let loginFlag = true
        NSUserDefaults.standardUserDefaults().setObject(dsi, forKey: "dsi")
        NSUserDefaults.standardUserDefaults().setObject(loginFlag, forKey: "loginFlag")
        self.dismissViewControllerAnimated(true, completion: {})
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

}
