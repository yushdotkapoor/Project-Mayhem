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
    @IBOutlet weak var purchaseprice: UILabel!
    @IBOutlet weak var betterHintButton: UIButton!
    @IBOutlet weak var purchaseRestore: CustomButtonOutline!
    @IBOutlet weak var welcStatementButton: CustomButtonOutline!
    @IBOutlet weak var feedbackButton: CustomButtonOutline!
    @IBOutlet weak var fiveHintsButton: UIButton!
    @IBOutlet weak var fiveHintPurchasePrice: UILabel!
    @IBOutlet weak var fiveHintsDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        version.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "null")"
        
        let volume = game.float(forKey: "volume")
        let sensitive = game.bool(forKey: "photosensitive")
        
        flashingSwitch.setOn(sensitive, animated: false)
        
        slider.value = volume
        
        purchaseRestore.setupButton()
        welcStatementButton.setupButton()
        feedbackButton.setupButton()
        
        checkIfPurchased()
        
        /*
         donateLabel.isUserInteractionEnabled = true
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donate(tapGestureRecognizer:)))
         donateLabel.addGestureRecognizer(tapGesture)
         */
    }
    
    func checkIfPurchased() {
        
        let numPurchase = game.integer(forKey: "fivePackPurchaseCount")
        let numHints = game.integer(forKey: ProjectMayhemProducts.fiveHints)
        //let lvlsToUnlock = 15 - (((numPurchase) * 5) - numHints)
        
        if numPurchase > 0 && numHints > 0 {
            fiveHintsDescription.text = "Purchase an Extra Five Hints\nUnlockable Hints: \(numHints)/15"
        } else {
            fiveHintsDescription.text = "Purchase Extra Hints For Five Levels"
        }
        
        
        let allHintsUnlocked = ProjectMayhemProducts.store.isProductPurchased(ProjectMayhemProducts.hints)
        if allHintsUnlocked {
            purchaseprice.text = "Purchased"
            purchaseprice.font = purchaseprice.font.withSize(14)
            purchaseprice.minimumScaleFactor = 0.4
            betterHintButton.tintColor = .gray
            betterHintButton.isUserInteractionEnabled = false
            
            fiveHintPurchasePrice.text = "All Hints Unlocked"
            fiveHintPurchasePrice.font = fiveHintPurchasePrice.font.withSize(14)
            fiveHintPurchasePrice.minimumScaleFactor = 0.4
            fiveHintsButton.tintColor = .gray
            fiveHintsButton.isUserInteractionEnabled = false
            fiveHintsDescription.text = "All hints have been unlocked."
            return
        } else {
            purchaseprice.text = "$\(getIAP(productIdentifier: ProjectMayhemProducts.hints).price)"
        }
        
        if game.integer(forKey: "fivePackPurchaseCount") >= 3 {
            purchaseprice.text = "All Hints Unlocked"
            purchaseprice.font = purchaseprice.font.withSize(14)
            purchaseprice.minimumScaleFactor = 0.4
            betterHintButton.tintColor = .gray
            betterHintButton.isUserInteractionEnabled = false
            
            fiveHintPurchasePrice.text = "Max Purchased"
            fiveHintPurchasePrice.font = purchaseprice.font.withSize(14)
            fiveHintPurchasePrice.minimumScaleFactor = 0.4
            fiveHintsButton.tintColor = .gray
            fiveHintsButton.isUserInteractionEnabled = false
            return
        } else {
            fiveHintPurchasePrice.text = "$\(getIAP(productIdentifier: ProjectMayhemProducts.fiveHints).price)"
        }
    }
    
    
    
    @IBAction func feedback(_ sender: Any) {
        //sendEmail()
        rList.removeAll()
        
        var selectNavigation = "MessagesNavigation"
        
        if (game.string(forKey: "key") == "ADMIN") {
            selectNavigation = "AdminNavigation"
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: selectNavigation)
        self.present(controller, animated: true, completion: nil)
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
        let product = getIAP(productIdentifier: ProjectMayhemProducts.hints)
        ProjectMayhemProducts.store.buyProduct(product, funcTo: checkIfPurchased)
    }
    
    
    @IBAction func fiveHints(_ sender: Any) {
        let product = getIAP(productIdentifier: ProjectMayhemProducts.fiveHints)
        ProjectMayhemProducts.store.buyProduct(product, funcTo: checkIfPurchased)
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
