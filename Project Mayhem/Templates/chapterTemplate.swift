//
//  chapterTemplate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/24/20.
//

import UIKit

class chapterTemplate: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func complete() {
        //game.setValue(true, forKey: "chap1")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        //self.performSegue(withIdentifier: "chap1ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        // self.performSegue(withIdentifier: "chap1ToChap2", sender: nil)
    }
    
    
    @IBAction func hint(_ sender: Any) {
        if menuState {
            //if menu open and want to close
            dismissAlert()
        }
        else {
            menuState = true
            //if menu closed and want to open
            hint.rotate(rotation: 0.49999, duration: 0.5, option: [])
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert.showAlert(message: "", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
}
