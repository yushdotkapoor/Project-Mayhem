//
//  chapter8.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21.
//

import UIKit

class chapter8: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var todo: UILabel!
    @IBOutlet weak var never: UILabel!
    @IBOutlet weak var no: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var settings: UIImageView!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    var customAlert = HintAlert()
    
    override func viewDidLoad() {
           super.viewDidLoad()
        game.setValue("chap8", forKey: "active")
        settings.alpha = 0.1
        
        if !game.bool(forKey: "settingsValueChanged") {
            UserDefaults.standard.set(true, forKey: "enabled_preference")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changed), name: UserDefaults.didChangeNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func complete() {
        NotificationCenter.default.removeObserver(self)
        game.setValue(true, forKey: "chap8")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    @objc func changed() {
        let multi = game.string(forKey: "multi_value")
        let text = game.string(forKey: "name_preference")
        let toggle = game.bool(forKey: "enabled_preference")
        let slider = game.float(forKey: "slider_preference")
        
        var one = false
        var two = false
        var three = false
        var four = false
        
        if multi == "good" {
            todo.textColor = UIColor.green
            one = true
        }
        else {
            todo.textColor = UIColor.white
            one = false
        }
        if text == "stop" {
            never.textColor = UIColor.green
            two = true
        }
        else {
            never.textColor = UIColor.white
            two = false
        }
        if toggle == false {
            no.textColor = UIColor.green
            three = true
        }
        else {
            no.textColor = UIColor.white
            three = false
        }
        if slider > 0.45 && slider < 0.55 {
            balance.textColor = UIColor.green
            four = true
        }
        else {
            balance.textColor = UIColor.white
            four = false
        }
        
        if one && two && three && four {
            complete()
            game.setValue(true, forKey: "settingsValueChanged")
        }
    }
    

    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap8ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap8ToChap9", sender: nil)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        changed()
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
            customAlert = HintAlert()
            customAlert.showAlert(message: "8", viewController: self, hintButton: hint, toolbar: toolbar)
        }
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }


}
