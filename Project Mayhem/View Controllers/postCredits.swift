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
    @IBOutlet weak var titl: UILabel!
    @IBOutlet weak var dev: UILabel!
    @IBOutlet weak var thx: UILabel!
    @IBOutlet weak var music: UILabel!
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var leave: UIButton!
    @IBOutlet weak var review: UIButton!
    @IBOutlet weak var merch: UILabel!
    @IBOutlet weak var merchDescription: UILabel!
    
    let customAlert = HintAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titl.text = "Credits".localized()
        dev.text = "Developer".localized()
        thx.text = "Vision Consolidated thanks you for playing Project Mayhem".localized()
        music.text = "Music By".localized()
        let j1 = "Those who thrive in Mayhem, are the silent rulers of all".localized()
        quote.text = "\"\(j1)\"".localized()
        leave.setTitle("Leave Feedback".localized(), for: .normal)
        review.setTitle("Review on App Store".localized(), for: .normal)
        merch.text = "Buy Our Merchandise".localized()
        merchDescription.text = "We have Project Mayhem hoodies, shirts, masks, and more! Tap the picture below to Check it out!".localized()
        
        toolbar.add3DMotionShadow()
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
        let l1 = "Did you Enjoy".localized()
        let alert = UIAlertController(title: "\(l1) Project Mayhem?", message: "Please consider leaving a rating or review!".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave Star Rating on App Store".localized(), style: .default, handler: { [weak self]_ in
            guard let scene = self?.view.window?.windowScene else {
                print("no scene")
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }))
        alert.addAction(UIAlertAction(title: "Leave Review on App Store".localized(), style: .default, handler: { _ in
            self.writeReview()
        }))
        alert.addAction(UIAlertAction(title: "Leave Feedback to Developer".localized(), style: .default, handler: { _ in
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
    
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "postCreditsToHome", sender: nil)
    }
    
    
}
