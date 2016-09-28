//
//  ViewController.swift
//  iOS-Beacon-POC
//
//  Created by Ernesto on 9/28/16.
//  Copyright © 2016 egomez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet var welcomePopup: UIView!
    @IBOutlet var feedbackPopup: UIView!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var welcomeButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var thanksButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onWelcomeButton(sender: AnyObject) {
        view.addSubview(welcomePopup)
//        let bottomConstraint = welcomePopup.bottomAnchor.constraintEqualToAnchor(backgroundLogo.bottomAnchor)
//        let leftConstraint = welcomePopup.leftAnchor.constraintEqualToAnchor(backgroundLogo.leftAnchor)
//        let rightConstraint = welcomePopup.rightAnchor.constraintEqualToAnchor(backgroundLogo.rightAnchor)
//        let topConstraint = welcomePopup.topAnchor.constraintEqualToAnchor(backgroundLogo.topAnchor)
        let heightConstraint = welcomePopup.heightAnchor.constraintEqualToConstant(160)
        let widthConstraint = welcomePopup.widthAnchor.constraintEqualToConstant(240)
        NSLayoutConstraint.activateConstraints([heightConstraint, widthConstraint])
        
        view.layoutIfNeeded()
    }

    @IBAction func onFeedbackButton(sender: AnyObject) {
        view.addSubview(feedbackPopup)
        
        view.layoutIfNeeded()
    }
    
    @IBAction func onThanksButton(sender: AnyObject) {
        self.welcomePopup.removeFromSuperview()
    }
    
    @IBAction func onSubmitButton(sender: AnyObject) {
        self.feedbackPopup.removeFromSuperview()
    }
}

