//
//  MainScreen.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/21/20.
//

import UIKit
import OneSignal

class MainScreen: UIViewController {
    
    @IBOutlet weak var enter: CustomButton!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var tearDrop: CustomButton!
    @IBOutlet weak var dropTop: NSLayoutConstraint!
    @IBOutlet weak var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let c = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        tearDrop.setupButton(color: c, pressColor: UIColor.black)
        enter.setupButton(color: c, pressColor: UIColor.black)
        
        if !videosCurrentlyDownloading && urlDict.isEmpty {
            if !game.bool(forKey: "useCellular") && game.bool(forKey: "onCellular")  {
                print("first node")
                return
            }
            else {
                print("second node")
                //uploadVideos()
                downloadVideos()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let intro = game.bool(forKey: "introViewed")
        if intro == false {
            performSegue(withIdentifier: "mainToIntroduction", sender: self)
        }
        
        lbl.fadeIn()
        
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.enterCenterConstraint.constant -= self.view.bounds.width
            self.logoCenterConstraint.constant += self.view.bounds.width
            self.dropTop.constant -= self.view.bounds.height - self.tearDrop.bounds.origin.y + 30
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterCenterConstraint.constant += view.bounds.width
        logoCenterConstraint.constant -= view.bounds.width
        dropTop.constant += view.bounds.height - tearDrop.bounds.origin.y + 30
        lbl.alpha = 0.0
    }
    
    @IBAction func Credits(_ sender: Any) {
        self.performSegue(withIdentifier: "mainToCredits", sender: nil)
    }
    
    @IBAction func enter(_ sender: Any) {
        self.performSegue(withIdentifier: "MainScreenToLevels", sender: nil)
    }
}
 
