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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes.text = "Soon, you may be prompted the following:\n\n \"Project Mayhem\" would like permission to track you across apps and websites owned by other companies\n\nI reccomend selecting the option NOT to track because it has no real benefit in gameplay, it is just used for analytics when you make in-app purchases etc.\n\nThis game was free to download; however, many of the levels will remain locked until you purchase the rest of the game. I wanted to be clear about this because I believe that being transparent builds trust! I purposely do not have ads in this game becuase I personally do not like the look and the clutter that ads make, hence why payment is required to play the full version. You'll be supporting an aspiring developer!\n\nThis game utilizes many of the iPhone's capabilities, many of which require permission from you. All of these capabilities are used for gameplay only and it is possible that the game may not progress without them.\n\nIf you ever want to leave feedback or get stuck, please don't hesitate to email me! My email is listed in the settings tab.\n\nYou can view this page in the settings tab at any time. Good luck, you will need it!"
        
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
        performSegue(withIdentifier: "IntroductionToMain", sender: self)
        }
    }

}
