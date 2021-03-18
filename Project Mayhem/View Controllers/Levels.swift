//
//  Levels.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit
import Speech
import LocalAuthentication
import AVFoundation

let game = UserDefaults.standard

class Levels: UIViewController {
    
    @IBOutlet weak var chap15: CustomButtonOutline!
    @IBOutlet weak var chap14: CustomButtonOutline!
    @IBOutlet weak var chap13: CustomButtonOutline!
    @IBOutlet weak var chap12: CustomButtonOutline!
    @IBOutlet weak var chap11: CustomButtonOutline!
    @IBOutlet weak var chap10: CustomButtonOutline!
    @IBOutlet weak var chap9: CustomButtonOutline!
    @IBOutlet weak var chap8: CustomButtonOutline!
    @IBOutlet weak var chap7: CustomButtonOutline!
    @IBOutlet weak var chap6: CustomButtonOutline!
    @IBOutlet weak var chap5: CustomButtonOutline!
    @IBOutlet weak var chap4: CustomButtonOutline!
    @IBOutlet weak var chap3: CustomButtonOutline!
    @IBOutlet weak var chap2: CustomButtonOutline!
    @IBOutlet weak var chap1: CustomButtonOutline!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var chap1Center: NSLayoutConstraint!
    @IBOutlet weak var chap2Center: NSLayoutConstraint!
    @IBOutlet weak var chap3Center: NSLayoutConstraint!
    @IBOutlet weak var chap4Center: NSLayoutConstraint!
    @IBOutlet weak var chap5Center: NSLayoutConstraint!
    @IBOutlet weak var chap6Center: NSLayoutConstraint!
    @IBOutlet weak var chap7Center: NSLayoutConstraint!
    @IBOutlet weak var chap8Center: NSLayoutConstraint!
    @IBOutlet weak var chap9Center: NSLayoutConstraint!
    @IBOutlet weak var chap10Center: NSLayoutConstraint!
    @IBOutlet weak var chap11Center: NSLayoutConstraint!
    @IBOutlet weak var chap12Center: NSLayoutConstraint!
    @IBOutlet weak var chap13Center: NSLayoutConstraint!
    @IBOutlet weak var chap14Center: NSLayoutConstraint!
    @IBOutlet weak var chap15Center: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    
    var del = 0.5
    
    override func viewDidLoad() {
           super.viewDidLoad()
        del = 0.5
        permissionsLord()
 
        //reset()
        //loadAll()
        MusicPlayer.shared.volumeControl(factor: 0.4)
        
        if !videosCurrentlyDownloading && urlDict.isEmpty {
            //uploadVideos()
            downloadVideos()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backTapped(gesture:)))
        logo.addGestureRecognizer(tapGesture)
        logo.isUserInteractionEnabled = true
        
    }
    
    @objc func backTapped(gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "levelsToMain", sender: nil)
        
    }
    
    func reset() {
        let reset = getData(string: "String") as! [String]
        
        for r in reset {
            game.setValue(false, forKey: r)
        }
        game.setValue(false, forKey: "postApocalypse")
        game.setValue(false, forKey: "apocalypse")
    }
    
    func loadAll() {
        let reset = getData(string: "String") as! [String]
        
        for r in reset {
            game.setValue(true, forKey: r)
        }
        game.setValue(true, forKey: "postApocalypse")
        game.setValue(false, forKey: "apocalypse")
    }
    
    func getData(string: String) -> [Any] {
        if string == "Center" {
        return [chap1Center, chap2Center, chap3Center, chap4Center, chap5Center, chap6Center, chap7Center, chap8Center, chap9Center, chap10Center, chap11Center, chap12Center, chap13Center, chap14Center, chap15Center] as [NSLayoutConstraint]
        }
        else if string == "String" {
            return ["chap1", "chap2", "chap3", "chap4", "chap5", "chap6", "chap7", "chap8", "chap9", "chap10", "chap11", "chap12", "chap13", "chap14", "chap15"] as [String]
        }
        else {
            return [chap1, chap2, chap3, chap4, chap5, chap6, chap7, chap8, chap9, chap10, chap11, chap12, chap13, chap14, chap15] as [CustomButtonOutline]
        }
    }
    
    func colorize() {
        let array = getData(string: "String") as! [String]
        
        let arrayButtons = getData(string: "Buttons") as! [CustomButtonOutline]
        var i = 0
        
        for button in arrayButtons {
            if button != chap1 {
                button.setupButton(color: UIColor.darkGray)
                button.isEnabled = false
            }
        }
        
        for chapter in array {
            let completion = game.bool(forKey: chapter)
            if completion {
                arrayButtons[i].setupButton(color: UIColor.green)
                arrayButtons[i].isEnabled = true
                if arrayButtons.count != i + 1 {
                    arrayButtons[i+1].setupButton(color: UIColor.white)
                    arrayButtons[i+1].isEnabled = true
                }
            }
            else {
                //scroll down to newest level
            }
            i += 1
        }
    }
    
    @objc func visionTrailer() {
        game.setValue(false, forKey: "apocalypse")
        game.setValue(true, forKey: "postApocalypse")
        performSegue(withIdentifier: "LevelsToProjectVenom", sender: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let apocalypse = game.bool(forKey: "apocalypse")
        let postApocalypse = game.bool(forKey: "postApocalypse")
        
        if apocalypse {
            let button = CustomButtonOutline(frame: CGRect(x: -view.bounds.width, y: 200, width: 300, height: 40))
            button.setupButton(color: UIColor.white)
            button.setTitle("PROJECT VENOM", for: .normal)
            button.setTitleColor(.link, for: .normal)
            button.addTarget(self, action: #selector(visionTrailer), for: .touchUpInside)
            button.titleLabel?.font = UIFont(name: "Adonay", size: 25.0)
            view.addSubview(button)
            UIView.animate(withDuration: 0.5, delay: 1) {
                button.frame.origin.x = (UIScreen.main.bounds.width - 300) / 2
                self.view.layoutIfNeeded()
            }

        }
        else {
            if postApocalypse {
                let complete = game.bool(forKey: "projectVenom")
                let button = CustomButtonOutline(frame: CGRect(x: -view.bounds.width, y: chap15.frame.origin.y + 60, width: 300, height: 40))
                if complete {
                    button.setupButton(color: UIColor.green)
                }
                else {
                    button.setupButton()
                }
                button.setTitle("PROJECT VENOM", for: .normal)
                button.setTitleColor(.link, for: .normal)
                button.addTarget(self, action: #selector(visionTrailer), for: .touchUpInside)
                button.titleLabel?.font = UIFont(name: "Adonay", size: 25.0)
                scrollView.addSubview(button)
                UIView.animate(withDuration: 0.5, delay: 1.2) {
                    button.frame.origin.x = (UIScreen.main.bounds.width - 300) / 2
                    self.view.layoutIfNeeded()
                }
            }
            colorize()
            let centers = getData(string: "Center")
            
            for button in centers {
                animate(constraint: button as! NSLayoutConstraint)
            }
        }
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.logoWidth.constant *= 0.25
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let centers = getData(string: "Center")
        
        for button in centers {
            let b = button as! NSLayoutConstraint
            b.constant -= view.bounds.width
        }
 
    }
    
    func permissionsLord() {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let current = UNUserNotificationCenter.current()
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        DispatchQueue.main.async {
            switch speechStatus {
            case .denied, .restricted:
                print("Transcription permission was declined.")
                self.alert(title: "Uh-Oh", message: "You must enable Speech Transcription in the Settings tab to have full access to the app. Go to Settings > Project Mayhem > Notifications > Turn on 'Speech Recognition'", actionTitle: "Okay", actions: {
                    UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                    })
                break
            case .notDetermined:
                self.requestTranscribePermissions()
                break
            default:
            break
            
            }
            current.getNotificationSettings(completionHandler: { (settings) in
                switch settings.authorizationStatus {
                case .denied:
                        self.alert(title: "Error", message: "You must agree to receive notifications from this app to continue. Go to Settings > Project Mayhem > Notifications > Turn on 'Allow Notifications'", actionTitle: "OK", actions: {
                            UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                            })
                    break
                case .ephemeral:
                        self.alert(title: "Error", message: "Make sure you can receive notifications from this app at all times", actionTitle: "OK", actions: {
                        UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                        })
                    break
                case .notDetermined:
                    self.requestNotificationAuthorization()
                    break
                case .authorized, .provisional:
                    break
                @unknown default:
                    break
                }
            })
            if microphoneStatus == .denied {
                self.alert(title: "Error", message: "You must agree to let Project Mayhem use your microphone for certain levels. Please go to Settings > Project Mayhem > Turn on 'Microphone'", actionTitle: "OK", actions: {
                    UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                    })
            }
            else if microphoneStatus == .undetermined {
                self.requestMicrophonePermissions()
            }
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized: // The user has previously granted access to the camera.
                break
                case .notDetermined: // The user has not yet been asked for camera access.
                    self.requestCameraPermissions()
                break
            case .denied, .restricted: // The user has previously denied access.
                self.alert(title: "Error", message: "You must agree to let Project Mayhem use your camera for certain levels. Please go to Settings > Project Mayhem > Turn on 'Camera'", actionTitle: "OK", actions: {
                    UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                    })
                break
            @unknown default:
                break
            }
        }
    }
    
    
    func animate(constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.5, delay: del, options: .curveEaseOut, animations: {
            constraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        })
        del += 0.05
    }
    
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { (granted) in
            if granted == .authorized {
                print("Transcription access granted")
            }
        }
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func requestMicrophonePermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
            print("microphone access granted")
            }
        }
    }
    
    
    func requestCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
               print("camera access granted")
            }
        }
    }


}



