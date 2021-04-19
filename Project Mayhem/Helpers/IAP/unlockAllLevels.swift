//
//  unlockAllLevels.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/27/21.
//

import Foundation
import UIKit
import StoreKit

class unlockAllLevels {
    
    var backView:UIView?
    var theScreenView:UIView?
    var theScreen:UIViewController?
    
    var segueKey:String?
    
    
    init(scrnview: UIViewController, key: String) {
        theScreenView = scrnview.view
        theScreen = scrnview
        segueKey = key
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapExit))
        tap.numberOfTapsRequired = 1
        theScreenView?.addGestureRecognizer(tap)
    }
    
    @objc func tapExit(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: theScreenView)
        let location:CGPoint = CGPoint(x: touchPoint.x, y: touchPoint.y)
        
        if !backView!.frame.contains(location) {
            cancel()
            UIView.animate(withDuration: 0.5, animations: {
                self.backView?.alpha = 0.0
            }, completion: { done in
                if done {
                    self.backView?.removeFromSuperview()
                }
            })
        }
    }
    
    func reqProducts() {
        ProjectMayhemProducts.store.requestProducts{ [weak self] success, products in
            guard self != nil else { return }
            if success {
                IAPs = products!
            }
            else {
                print("IAP import unsuccessful")
            }
        }
    }
    
    func purchase() {
        if ProjectMayhemProducts.store.isProductPurchased(ProjectMayhemProducts.unlocker) {
            theScreen?.performSegue(withIdentifier: segueKey!, sender: nil)
            print("already purchased")
        } else if IAPHelper.canMakePayments() {
            
            if !CheckInternet.Connection() {
                alert(title: "Error", message: "Make sure your internet connection is secure.", actionTitle: "Okay", actions: {
                    self.reqProducts()
                })
                cancel()
                return
            }
            else if IAPs == [] {
                print("no :(")
                alert(title: "Error", message: "There was an error downloading app information. Make sure your internet connection is secure.", actionTitle: "Okay", actions: {
                    self.reqProducts()
                })
                cancel()
                return
            }
            
            
            backView = UIView(frame: CGRect(x: 25, y: 90, width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.height - 200))
            backView!.alpha = 0.0
            backView!.layer.masksToBounds = true
            backView!.clipsToBounds = true
            backView!.layer.cornerRadius = 20
            backView?.backgroundColor = .darkGray
            
            
            let title = "Thank You For Trying Project Mayhem!"
            let lblwidth = backView!.bounds.size.width - 10
            let lblheight = heightForView(text: title, font: UIFont(name: "Helvetica", size: 25)!, width: lblwidth)
            let label = UILabel(frame: CGRect(x: 5, y: 5, width: lblwidth, height: lblheight))
            label.text = title
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica", size: 25)
            label.numberOfLines = 0
            label.textColor = .white
            
            var pr:NSDecimalNumber = 0
            for i in IAPs ?? [] {
                if i.productIdentifier == "com.YushRajKapoor.ProjectMayhem.unlockAllLevels"{
                    pr = i.price
                }
            }
            
            let content = "If you liked what you see so far, please support me and my future projects by purchasing the rest of the levels for $\(pr)! After all, the game has only started :)\n\n -Yush"
            let contentWidth = backView!.bounds.size.width - 20
            let contentHeight:CGFloat = 150
            let contentLabel = UILabel(frame: CGRect(x: 10, y: lblheight + 10, width: contentWidth, height: contentHeight))
            contentLabel.text = content
            contentLabel.numberOfLines = 0
            contentLabel.textAlignment = .center
            contentLabel.minimumScaleFactor = 0.1
            contentLabel.adjustsFontSizeToFitWidth = true
            contentLabel.font = UIFont(name: "Helvetica", size: 17)
            contentLabel.textColor = .white
            
            let button = CustomButtonOutline()
            button.frame = CGRect(x: (backView?.frame.size.width)! / 2 - 100, y: contentHeight + lblheight + 30, width: 200, height: 25)
            button.setupButton(color: .link)
            button.setTitle("Purchase All Levels", for: .normal)
            button.setTitleColor(.link, for: .normal)
            button.addTarget(self, action: #selector(goToPurchase), for: .touchUpInside)
            
            backView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 80, height: lblheight + contentHeight + 70)
            backView?.center = theScreenView!.center
            backView?.addSubview(label)
            backView?.addSubview(contentLabel)
            backView?.addSubview(button)
            theScreenView!.addSubview(backView!)
            theScreenView!.bringSubviewToFront(backView!)
            
            backView!.fadeIn()
            
        } else {
            print("Cannot Make Payments")
            
            alert(title: "Oh No!", message: "This device cannot make payments! Make sure you are signed into your Apple ID and that parental controls allow you to make a purchase.", actionTitle: "Okay!")
        }
    }
    
    func alert(title: String, message: String, actionTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        theScreen!.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String, actionTitle: String, actions: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: { action in actions()})
        
        alertController.addAction(defaultAction)
        theScreen!.present(alertController, animated: true, completion: nil)
    }
    
    func cancel() {
        theScreenView!.gestureRecognizers?.forEach(theScreenView!.removeGestureRecognizer)
    }
    
    @objc func goToPurchase() {
        for i in IAPs ?? [] {
            if i.productIdentifier == "com.YushRajKapoor.ProjectMayhem.unlockAllLevels"{
                ProjectMayhemProducts.store.buyProduct(i)
            }
        }
    }
}
