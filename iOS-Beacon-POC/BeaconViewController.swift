//
//  ViewController.swift
//  iOS-Beacon-POC
//
//  Created by Ernesto on 9/28/16.
//  Copyright © 2016 egomez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var welcomePopup: UIView!
    @IBOutlet var feedbackPopup: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var welcomeButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var thanksButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    
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

