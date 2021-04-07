//
//  Credits.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/2/21.
//

import UIKit
import MessageUI
import StoreKit

class Credits: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var flashingSwitch: UISwitch!
    @IBOutlet weak var dhruvSoundCloud: UIButton!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var cellularSwitch: UISwitch!
    @IBOutlet weak var purchaseprice: UILabel!
    @IBOutlet weak var betterHintButton: UIButton!
    @IBOutlet weak var purchaseRestore: CustomButtonOutline!
    @IBOutlet weak var welcStatementButton: CustomButtonOutline!
    @IBOutlet weak var feedbackButton: CustomButtonOutline!
    @IBOutlet weak var stuckButton: CustomButtonOutline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        version.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "null")"
        
        let volume = game.float(forKey: "volume")
        let sensitive = game.bool(forKey: "photosensitive")
        let cell = game.bool(forKey: "useCellular")
        
        flashingSwitch.setOn(sensitive, animated: false)
        cellularSwitch.setOn(cell, animated: false)
        
        slider.value = volume
        
        purchaseRestore.setupButton()
        welcStatementButton.setupButton()
        feedbackButton.setupButton()
        stuckButton.setupButton()
        
        if ProjectMayhemProducts.store.isProductPurchased(ProjectMayhemProducts.hints) {
            purchaseprice.text = "Purchased"
            purchaseprice.font = purchaseprice.font.withSize(14)
            purchaseprice.minimumScaleFactor = 0.4
            betterHintButton.tintColor = .gray
            betterHintButton.isUserInteractionEnabled = false
        }
        
        donateLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donate(tapGestureRecognizer:)))
        donateLabel.addGestureRecognizer(tapGesture)
        
    }
    
    
    @IBAction func stuck(_ sender: Any) {
        sendEmail(subject: "Given the circumstances, it seems that I have encountered a rather dreary situation where I simply, and I am unable to stress this enough, CANNOT.")
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
        openLink(st: "https://www.instagram.com/vision_consolidated/")
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
    
    
    @IBAction func betterHints(_ sender: Any) {
        print(IAPs![0].productIdentifier)
        for i in IAPs ?? [] {
            if i.productIdentifier == "com.YushRajKapoor.ProjectMayhem.betterHints"{
                ProjectMayhemProducts.store.buyProduct(i)
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        print(slider.value)
        game.setValue(slider.value, forKey: "volume")
        MusicPlayer.shared.volumeControl(factor: 0.4)
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        let state = flashingSwitch.isOn
        game.setValue(state, forKey: "photosensitive")
    }
    
    @IBAction func cellularSwitchChanged(_ sender: Any) {
        let state = cellularSwitch.isOn
        game.setValue(state, forKey: "useCellular")
    }
    
    
    @IBAction func restorePurchases(_ sender: Any) {
        ProjectMayhemProducts.store.restorePurchases()
        let alertController = UIAlertController(title: "Restore", message: "Purchase Restore Complete.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
        wait {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func statement(_ sender: Any) {
        game.setValue("settings", forKey: "active")
        performSegue(withIdentifier: "settingsToIntroduction", sender: self)
    }
    
    
    func sendEmail(subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["visionconsolidated@gmail.com"])
            mail.setSubject(subject)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func sendEmail() {
        sendEmail(subject: "Project Mayhem Feedback")
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
}
