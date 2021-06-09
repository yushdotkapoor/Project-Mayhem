//
//  postCredits.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/8/21.
//

import UIKit
import MessageUI
import StoreKit

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
        
        wait {
            self.actionForRating()
        }
    }
    
    @IBAction func merchSite(_ sender: Any) {
        openLink(st: "https://visionconsolidated.wixsite.com/website/project-mayhem-shop")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func actionForRating() {
        let alert = UIAlertController(title: "Did you Enjoy Project Mayhem?", message: "Please consider leaving a rating or review!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave Star Rating on App Store", style: .default, handler: { [weak self]_ in
            guard let scene = self?.view.window?.windowScene else {
                print("no scene")
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }))
        alert.addAction(UIAlertAction(title: "Leave Review on App Store", style: .default, handler: { _ in
            self.writeReview()
        }))
        alert.addAction(UIAlertAction(title: "Leave Feedback to Developer", style: .default, handler: { _ in
            self.leaveTheFeedback()
        }))
        present(alert, animated: true)
    }
    
    
    @IBAction func review(_ sender: Any) {
      writeReview()
    }
    
    func writeReview() {
        var components = URLComponents(url: URL(string: "https://itunes.apple.com/app/id1551711683")!, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "action", value: "write-review")]
        
        guard let writeReviewURL = components?.url else {
          return
        }
        
        UIApplication.shared.open(writeReviewURL)
    }
    
    
    @IBAction func feedback(_ sender: Any) {
        //sendEmail()
        leaveTheFeedback()
    }
    
    func leaveTheFeedback() {
        rList.removeAll()
        
        var selectNavigation = "MessagesNavigation"
        
        if (game.string(forKey: "key") == "ADMIN") {
            selectNavigation = "AdminNavigation"
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: selectNavigation)
        self.present(controller, animated: true, completion: nil)
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
