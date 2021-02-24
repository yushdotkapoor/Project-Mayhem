//
//  MainScreen.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/21/20.
//

import UIKit

class MainScreen: UIViewController {
    @IBOutlet weak var enter: CustomButton!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterCenterConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
           super.viewDidLoad()
        enter.setupButton(color: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0), pressColor: UIColor.black)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.enterCenterConstraint.constant += self.view.bounds.width
            self.logoCenterConstraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logoCenterConstraint.constant -= view.bounds.width
        enterCenterConstraint.constant -= view.bounds.width
    }
    
    @IBAction func enter(_ sender: Any) {
        if game.string(forKey: "name") == nil {
            self.performSegue(withIdentifier: "MainScreenToNameQuery", sender: nil)
        }
        else {
        self.performSegue(withIdentifier: "MainScreenToLevels", sender: nil)
        }
    }
}
 
