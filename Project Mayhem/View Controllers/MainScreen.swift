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
    
    var touched = 0
    
    override func viewDidLoad() {
           super.viewDidLoad()
        enter.setupButton(color: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0), pressColor: UIColor.black)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.enterCenterConstraint.constant -= self.view.bounds.width
            self.logoCenterConstraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterCenterConstraint.constant += view.bounds.width
        logoCenterConstraint.constant -= view.bounds.width
    }
    
    @IBAction func Credits(_ sender: Any) {
        let completed = game.bool(forKey: "credits")
        let name = game.string(forKey: "name")
        if name == nil {
            alert(title: "💧", message: "Come back later!", actionTitle: "Ok")
        }
        else if completed {
            self.performSegue(withIdentifier: "mainToCredits", sender: nil)
        }
        else {
        switch touched {
        case 0:
            alert(title: "No", message: "Don't touch me.", actionTitle: "Ok")
            touched += 1
            break
        case 1:
            alert(title: "Ummmm", message: "Can't you read??? Do. Not. Touch. Me.", actionTitle: "Ok")
            touched += 1
            break
        case 2:
            alert(title: "😡", message: "I swear to heck, if you touch me one more time, I will find out where you live, \(game.string(forKey: "name")!)", actionTitle: "Ok")
            touched += 1
            break
        case 3:
            game.setValue(true, forKey: "credits")
            alert(title: "Ugh", message: "Fine, I will let you through.", actionTitle: "Yay!") {
                self.performSegue(withIdentifier: "mainToCredits", sender: nil)
            }
            break
        default:
            break
        }
        }
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
 
