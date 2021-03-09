//
//  Credits.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/2/21.
//

import UIKit
import MessageUI

class Credits: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var flashingSwitch: UISwitch!
    @IBOutlet weak var dhruvSoundCloud: UIButton!
    @IBOutlet weak var version: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        version.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "null")"
        
        let volume = game.float(forKey: "volume")
        let sensitive = game.bool(forKey: "photosensitive")
        flashingSwitch.setOn(sensitive, animated: false)
        
        slider.value = volume
        
        donateLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donate(tapGestureRecognizer:)))
        donateLabel.addGestureRecognizer(tapGesture)
        
    }
    @IBAction func feedback(_ sender: Any) {
        sendEmail()
    }
    
    @IBAction func visionConsolidatedWebsite(_ sender: Any) {
        openLink(st: "https://visionconsolidated.wixsite.com/website/project-mayhem-shop")    }
    
    @IBAction func paypal(_ sender: Any) {
        openLink(st: "https://www.paypal.com/paypalme/yushkapoor")
    }
    
    @IBAction func instagram(_ sender: Any) {
        openLink(st: "https://www.instagram.com/yushrajkapoor/")
    }
    
    @IBAction func dhruvGoelWebsite(_ sender: Any) {
        openLink(st: "https://www.dhruvgoel.com")
    }
    
    @IBAction func dhruvSoundCloudLink(_ sender: Any) {
        openLink(st: "https://soundcloud.com/dhruvgoel")
    }
    
    @objc func donate(tapGestureRecognizer: UITapGestureRecognizer) {
        openLink(st: "https://www.paypal.com/paypalme/yushkapoor")
    }
    
    func openLink(st: String) {
        guard let url = URL(string: st) else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        print(slider.value)
        game.setValue(slider.value, forKey: "volume")
        MusicPlayer.shared.updateVolume()
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        let state = flashingSwitch.isOn
        game.setValue(state, forKey: "photosensitive")
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["visionconsolidated@gmail.com"])
            mail.setSubject("Project Mayhem Feedback")

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
}
