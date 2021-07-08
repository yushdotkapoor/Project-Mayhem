//
//  Introduction.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 4/6/21.
//

import UIKit

class Introduction: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var t2n: UILabel!
    @IBOutlet weak var hope: UILabel!
    
    @IBOutlet weak var greet: UILabel!
    @IBOutlet weak var welc: UILabel!
    @IBOutlet weak var changeLanguage: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    
    
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    
    var pickerSelection:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let active = game.string(forKey: "active")
        if active != "settings" {
            downloadVideos(vidNames: ["Chap1Intro"])
        }
        
        setLocalizations()
    }
    
    func setLocalizations() {
        initLanguagesArray()
        
        t2n.text = "Things to note:".localized()
        hope.text = "I hope you enjoy this game as much as I did making it!".localized()
        welc.text = "Vision Consolidated welcomes you to Project Mayhem".localized()
        greet.text = "Greetings".localized()
        changeLanguage.text = "Change Language:".localized()
        
        let lan = game.string(forKey: "AppleLanguage")!
        let languageT = getLanguageFromCode(code: lan)
        languageButton.setTitle(languageT, for: .normal)
        
       
        let p4 = "You will not need any external devices although a paper, writing utensil, a wrinkly brain, and access to internet can be very useful.".localized()
        let p5 = "This game utilizes many of the iPhone's capabilities, many of which require permission from you. All of these capabilities are used for gameplay ONLY and it is possible that the game may not progress without them.".localized()
        let p6 = "If you ever want to leave feedback or get stuck on a level, please don't hesitate to contact me! You can directly message me in the settings page or from the main chapter menu.".localized()
        let p7 = "You can view this page in the settings tab at any time. Good luck, you will need it!".localized()
        
        notes.text = "\(p4)\n\n\(p5)\n\n\(p6)\n\n\(p7)"
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        let active = game.string(forKey: "active")
        if active == "settings" {
            performSegue(withIdentifier: "introductionToSettings", sender: self)
        }
        else {
            performSegue(withIdentifier: "IntroToDownloads", sender: self)
        }
    }
    
    
    @IBAction func changeTheLanguage(_ sender: Any) {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.black
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        let languageRow = getRowOfLanguageCode(code: game.string(forKey: "AppleLanguage")!)
        
        picker.selectRow(languageRow, inComponent: 0, animated: false)
        
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)
                
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .black
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.onDoneButtonTapped))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.view.addSubview(toolBar)
    
    
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        
        
        if let row = pickerSelection {
        let languageString = getLanguage(row: row)
        print(languageString)
        
        let lang = getLanguageCode(row: row)
        
        Bundle.setLanguage(lang)
        game.set(lang, forKey: "AppleLanguage")
        game.synchronize()
        
        languageButton.setTitle(languageString, for: .normal)
        setLocalizations()
        
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let lan = getLanguage(row: row).localized()
        var str = ""
        if let cd = languages[lan] {
            str = "\(lan) (\(cd))"
        } else {
            str = "\(lan)"
            let notification = PushNotificationSender()
            notification.sendPushNotification(to: administratorToken ?? "cLijGH7NpUsFvB9hrlLlUe:APA91bFAyDwvtWiMUSsG9JZyH8909Xjd61oUpz6lVENaqVNO-zgbBKc3x_9v0ltBjmG9ZVvXLDw_2s-DrnYEngnCUv765B-wFthOL_YAmBgEP5xnfx0690LOCx8UcHGd4IzNLbBM8rnI", title: "Crash Report", body: "Root Language: \(Locale.preferredLanguages)\nSet Language: \(lan)")
        }
        return str
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = row
    }
    
    
}
