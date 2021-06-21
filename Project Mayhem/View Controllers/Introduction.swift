//
//  Introduction.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 4/6/21.
//

import UIKit
import AppTrackingTransparency

class Introduction: UIViewController {
    
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var t2n: UILabel!
    @IBOutlet weak var hope: UILabel!
    
    @IBOutlet weak var greet: UILabel!
    @IBOutlet weak var welc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let active = game.string(forKey: "active")
        if active != "settings" {
            downloadVideos()
        }
        t2n.text = "Things to note:".localized()
        hope.text = "I hope you enjoy this game as much as I did making it!".localized()
        welc.text = "Vision Consolidated welcomes you to Project Mayhem".localized()
        greet.text = "Greetings".localized()
        
        let p1 = "You may be prompted the following:".localized()
        let p2 = " would like permission to track you across apps and websites owned by other companies".localized()
        let p3 = "You do NOT have to select the option to track because it has no real benefit in gameplay, it is just used for analytics such as where you downloaded the game from.".localized()
        let p4 = "You will not need ANY external devices although a paper, writing utensil, a wrinkly brain, and access to internet can be very useful.".localized()
        let p5 = "I'm going to be as transparent about the game as I possibly can because I know that this will build trust. This game utilizes many of the iPhone's capabilities, many of which require permission from you. All of these capabilities are used for gameplay ONLY and it is possible that the game may not progress without them.".localized()
        let p6 = "If you ever want to leave feedback or get stuck on a level, please don't hesitate to contact me! You can directly message me in the settings page or from the main chapter menu.".localized()
        let p7 = "You can view this page in the settings tab at any time. Good luck, you will need it!".localized()
        
        notes.text = "\(p1)\n\n\"Project Mayhem\"\(p2)\n\n\(p3)\n\n\(p4)\n\n\(p5)\n\n\(p6)\n\n\(p7)"
        
        
        wait(time:15, actions: {
            ATTrackingManager.requestTrackingAuthorization { (status) in }
        })
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        game.setValue(true, forKey: "introViewed")
        let active = game.string(forKey: "active")
        if active == "settings" {
            performSegue(withIdentifier: "introductionToSettings", sender: self)
        }
        else {
            performSegue(withIdentifier: "IntroToDownloads", sender: self)
        }
    }
    
}
