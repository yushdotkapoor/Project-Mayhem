//
//  postCredits.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/8/21.
//

import UIKit
import MessageUI

class postCredits: UIViewController, MFMailComposeViewControllerDelegate {
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
        hint.alpha = 0.0
        hint.isUserInteractionEnabled = false
    }
    
    @IBAction func merchSite(_ sender: Any) {
        openLink(st: "https://visionconsolidated.wixsite.com/website/project-mayhem-shop")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @IBAction func feedback(_ sender: Any) {
        sendEmail()
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
    
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "postCreditsToHome", sender: nil)
    }
    
    
}
