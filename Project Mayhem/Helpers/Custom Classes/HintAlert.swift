//
//  HintAlert.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/13/21.
//

import UIKit
import StoreKit

class HintAlert: NSObject, UIScrollViewDelegate {
    
    private let backgroundView:UIView = UIView()
    
    private var hint:UIButton?
    
    private var msgCt = 0
    
    var blurViews:[String:[UIView]] = [:]
    
    var tier1Hint = ["1":"Leave what?".localized(), "2":"How could you make sure that you can hear everything?".localized(),"3":"Tappity tap".localized(),"4":"Move your phone a bit. Just kidding, a lot.".localized(),"5":"","5Perm":"","6":"","7":"Rule number 1: have patience. Rule number 2: have good memory skills. Rule number 3: see what happens when you tap (r1,c2).".localized(),"8":"What's that on the top right?".localized(),"9":"These are not just some random characters! Have you ever heard of 🐷🖊️ Cipher?".localized(),"10":"I wonder what I could do with a QR code, once it is aligned".localized(),"11.1":"Maybe the morse code at the top and the coordinates at the bottom have some sort of relationship.".localized(),"11.2":"Great works from a great man, who indeed has a name!".localized(),"11.2Perm":"","12.1": "Battery, battery, battery. It bugs me that the battery isn't completely full".localized(), "12.2":"Roses are red, violets are blue, I'm pretty sure that this is a date. What are you supposed to do? \"Get in a blue box and get your timey wimey on.\"".localized(),"12.3":"Is there a way to change the size of text?".localized(),"13.1":"Dude c'mon. The text on the screen IS the hint".localized(),"13.2":"Earthquake simulator?".localized(),"13.3":"Earthquake simulator?: Look for the red".localized(),"14": "a=swipe\nb=right\nc=down\n-(a*(-b)*c)/b","15.1":"When I am black, I am actually white. When I am white, I am actually black. What am I?".localized(),"15.2":"The answer is not in this level. Look closely 👁️".localized()]
    
    var tier2Hint = ["1":"Maybe it's best if you go home.".localized(), "2":"If you were on the phone and could not hear the other person on speaker, what would you do?".localized(),"3":"Tap the little circles simultaneously.".localized(),"4":"Stright lines, fast movements, phone flat.".localized(),"5":"\"A\" is known as a musical note and has different pitches. Remember, nothing is off limits!".localized(),"5Perm":"\"A\" is known as a musical note and has different pitches. Remember, nothing is off limits!".localized(),"6":"Morse code, isn't it? Let's see what the internet can do for you.".localized(),"7":"I suggest writing down a grid and tapping around to see what happens.".localized(),"8":"I wonder what happens if we look for the app settings?".localized(),"9":"Use your resources to decode this message".localized(),"10":"Scan the QR code and see what pops up.".localized(),"11.1":"","11.2":"Say the name of the playright!".localized(),"11.2Perm":"Say the name of the playright!".localized(),"12.1": "Let's fill that battery.".localized(), "12.2":"Maybe we can travel back in time.".localized(),"12.3":"It's possible that there is a setting to change the general size of fonts?".localized(),"13.1":"You gotta physically move back".localized(),"13.2":"Let's undo.".localized(),"13.3":"Let's keep undoing and see what the red letters spell out.".localized(),"14":  "As the Curtain Rose, the people cheered and the bootleggers took Pictures.".localized(),"15.1":"Make sure you make the SMART move.".localized(),"15.2":"There are 15 hidden letters in the levels prior.".localized()]
    
    
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .darkGray
        alert.clipsToBounds = true
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 15
        return alert
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isScrollEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private let titleLabel:UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Hint".localized()
        lbl.font = lbl.font.withSize(25)
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    
    var btn = UIButton()
    
    private var d1 = UIView()
    private var d2 = UIView()
    
    private let button = CustomButtonOutline()
    private let stuck = CustomButtonOutline()
    
    private let gradient = CAGradientLayer()
    
    var message1Height:CGFloat?
    var message2Height:CGFloat?
    
    var controller:UIViewController?
    
    var dictRef = ""
    
    var tb:UIStackView?
    
    
    @objc func tapExit(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: backgroundView)
        let location:CGPoint = CGPoint(x: touchPoint.x, y: touchPoint.y)
        
        if !alertView.frame.contains(location) {
            cancel()
            dismissAlert()
        }
    }
    
    func cancel() {
        backgroundView.gestureRecognizers?.forEach(backgroundView.removeGestureRecognizer)
    }
    
    let m1 = "do re mi fa so laaaaaaaaaaaaaaaaaaaaaaaaaaaaa".localized()
    let m2  = "Also, Nice ;)".localized()
    let m3 = "It seems that you have Microphone permissions turned off. This level requires the microphone to pass. However, if you're adamant or if this does not apply to you, then contact me and I will sort things out.".localized()
    let m4 = "Seems like this is a coded message!".localized()
    let m5 = "Also, don't curse in a castle, it's bad for our reputation.".localized()
    let m6 = "Great works from a great man, who indeed has a name!".localized()
    let m7 = "It seems that you have Microphone or Speech Recognition permissions turned off. This level requires Speech Recognition to pass. However, if you're adamant or if this does not apply to you, then contact me and I will sort things out.".localized()
    let m8 = "a=swipe".localized()
    let m9 = "b=right".localized()
    let m10 = "c=down".localized()
    let m11 = "-(a*(-b)*c)/b" //not localized
    let m12 = "Roses are red, violets are blue, I'm pretty sure that this is a date. What are you supposed to do?".localized()
    let m13 = "Get in a blue box and get your timey wimey on.".localized()
    let m14 = "is known as a musical note and has different pitches. Remember, nothing is off limits!".localized()
    let m15 = "The coordinates at the bottom correspond to the location of a character in the letter. The second part to the morse code is as follows:".localized()
    
    func showAlert(message: String, viewController: UIViewController, hintButton: UIButton, toolbar: UIStackView) {
        tier1Hint["5"] = "\(m1)\n\n\(m2)"
        tier1Hint["5Perm"] = "\(m1)\n\n\(m3)"
        tier1Hint["6"] = "\(m4)\n\n\(m5)"
        tier1Hint["11.2Perm"] = "\(m6)\n\n\(m7)"
        tier1Hint["14"] = "\(m8)\n\(m9)\n\(m10)\n\(m11)"
        tier1Hint["12.2"] = "\(m12) \"\(m13)\""
        tier2Hint["5"] = "\"A\" \(m14)"
        tier2Hint["5Perm"] = "\"A\" \(m14)"
        tier2Hint["11.1"] = "\(m15) ----graph, ----ence, ----acter."
        
        hint = hintButton
        controller = viewController
        reqProducts()
        dictRef = message
        tb = toolbar
        
        okActuallyShowTheHint(hintButton: hintButton)
    }
    
    func okActuallyShowTheHint(hintButton: UIButton) {
        guard let targetView = controller?.view else {
            return
        }
        msgCt = 0
        backgroundView.frame = targetView.frame
        targetView.addSubview(backgroundView)
        
        alertView.isUserInteractionEnabled = true
        
        var width = targetView.frame.size.width-80
        if width > 500 {
            width = 500
        }
        
        alertView.frame = CGRect(x: 0, y: 0, width: width, height: 100)
        alertView.isHidden = true
        alertView.alpha = 0.0
        
        message1Height = heightForView(text: self.tier1Hint[dictRef]!, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
        message2Height = heightForView(text: self.tier2Hint[dictRef]!, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
        
        let titleLabelHeight = heightForView(text: "Hint".localized(), font: UIFont(name: "Helvetica", size: 25.0)!, width: alertView.frame.size.width - 10)
        //create a title label
        titleLabel.frame = CGRect(x: 5, y: 5, width: alertView.frame.size.width - 10, height: titleLabelHeight)
        
        //set up scrollView
        scrollView.contentSize = CGSize(width: alertView.frame.size.width*2, height: alertView.frame.size.height)
        scrollView.delegate = self
        
        //set up button
        button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: message1Height! + titleLabelHeight + 55, width: 75, height: 25)
        button.setupButton()
        button.setTitle("Close".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        
        //set up stuck button
        stuck.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: message1Height! + titleLabelHeight + 55, width: 75, height: 25)
        stuck.setupButton()
        stuck.setTitle("Stuck?".localized(), for: .normal)
        stuck.setTitleColor(.white, for: .normal)
        stuck.addTarget(self, action: #selector(chat), for: .touchUpInside)
        
        //set up dot stack
        d1 = UIView(frame: CGRect(x: alertView.frame.size.width / 2 - 15, y: message1Height! + titleLabelHeight + 15, width: 8, height: 8))
        d1.layer.cornerRadius = 4
        d2 = UIView(frame: CGRect(x: alertView.frame.size.width / 2 + 5, y: message1Height! + titleLabelHeight + 15, width: 8, height: 8))
        d2.layer.cornerRadius = 4
        
        
        //resize alertView
        alertView.frame = CGRect(x: 0, y: 0, width: width, height: message1Height! + titleLabel.frame.size.height + 95)
        alertView.center = targetView.center
        gradient.colors = [UIColor(named: "MayhemBlue")!.cgColor, UIColor(named: "MayhemGray")!.cgColor]
        gradient.frame = alertView.bounds
        alertView.layer.addSublayer(gradient)
        backgroundView.addSubview(alertView)
        
        alertView.addSubview(titleLabel)
        alertView.addSubview(d1)
        alertView.addSubview(d2)
        
        //update up scrollView
        scrollView.frame = alertView.bounds
        
        showTheMeat(xRef: 0)
        
        
        //animate alertView in
        UIView.animate(withDuration: 0.5, animations: {
            self.alertView.isHidden = false
            self.alertView.alpha = 1.0
        })
        bouncer(num: 0)
        alertView.add3DTileMotion()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapExit))
        tap.numberOfTapsRequired = 1
        backgroundView.addGestureRecognizer(tap)
    }
    
    func showTheMeat(xRef:CGFloat) {
        showTheMeat(xRef: xRef, createBlur: true)
    }
    
    func showTheMeat(xRef:CGFloat, createBlur: Bool) {
        var text = tier1Hint[dictRef]
        var msgHt:CGFloat = 0
        
        if msgCt == 0 {
            msgHt = message1Height!
            alertView.addSubview(scrollView)
            alertView.addSubview(button)
            alertView.addSubview(stuck)
        } else if msgCt == 1 {
            text = tier2Hint[dictRef]
            msgHt = message2Height!
        }
        
        //create the message label
        let messageLabel = UILabel(frame: CGRect(x: xRef + 10, y: titleLabel.frame.size.height + 5, width: alertView.frame.size.width - 20, height: msgHt))
        messageLabel.numberOfLines = 0
        messageLabel.text = text
        messageLabel.font = messageLabel.font.withSize(16)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        
        let blur = UIView()
        blur.frame = messageLabel.frame
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blur.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.addSubview(blurEffectView)
        blur.layer.cornerRadius = 10
        blur.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showHint(_:)))
        blur.addGestureRecognizer(tap)
        
        
        let tapMe = UILabel()
        tapMe.frame = messageLabel.frame
        tapMe.font = tapMe.font.withSize(14)
        tapMe.textAlignment = .center
        tapMe.textColor = .white
        tapMe.text = "Tap to view Hint!".localized()
        tapMe.startPulse()
        
        
        blurViews["\(msgCt)"] = [blur, tapMe]
        
        scrollView.addSubview(messageLabel)
        if createBlur {
            scrollView.addSubview(blur)
            scrollView.addSubview(tapMe)
        }
        msgCt += 1
        
        if msgCt == 1 {
            checkIfPaywallRequired()
        } else if msgCt == 2 {
            bouncer(num: 1)
            controller?.view.bringSubviewToFront(tb!)
        }
    }
    
    func stopAnimation(index: String) {
        let b = blurViews[index]
        let t = b![1]
        
        t.stopPulse()
    }
    
    func stopAllAnimations() {
        for i in blurViews.keys {
            let b = blurViews[i]
            let t = b![1]
            
            t.stopPulse()
        }
    }
    
    @objc func showHint(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        impact(style: .heavy)
        let pageNumber = round(scrollView.contentOffset.x / (scrollView.frame.size.width)*1)
        let st = "\(Int(pageNumber))"
        let arr = blurViews[st]
        stopAnimation(index: st)
        for i in arr! {
            i.fadeOut()
            wait {
                i.removeFromSuperview()
            }
        }
    }
    
    func checkIfPaywallRequired() {
        let xRef = alertView.frame.size.width
        let hintNum = game.integer(forKey: ProjectMayhemProducts.fiveHints)
        var ref = Int.parse(from: dictRef)!
        if ref > 50 {
            ref = ref / 10
        }
        
        if ProjectMayhemProducts.store.isProductPurchased(ProjectMayhemProducts.hints) || game.bool(forKey: "hint\(ref)") {
            message2Height = heightForView(text: tier2Hint[dictRef]!, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
            showTheMeat(xRef: xRef)
        } else {
            if hintNum > 0 {
                //ask to use hint
                // display hints remaining
                
                let t1 = "Tap here if you would like to use one of your remaining hints".localized()
                let t2 = "Hints remaining:".localized()
                let buttontext = "\(t1)\n\(t2) \(hintNum)"
                
                message2Height = heightForView(text: buttontext, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
                
                let blur = UIView(frame: CGRect(x: xRef + 10, y: titleLabel.frame.size.height + 5, width: alertView.frame.size.width - 20, height: message2Height!))
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = blur.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blur.addSubview(blurEffectView)
                blur.layer.cornerRadius = 10
                blur.clipsToBounds = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.useHint))
                blur.addGestureRecognizer(tap)
                
                
                let tapMe = UILabel()
                tapMe.frame = blur.frame
                tapMe.numberOfLines = 0
                tapMe.font = tapMe.font.withSize(14)
                tapMe.textAlignment = .center
                tapMe.textColor = .white
                tapMe.text = buttontext
                
                blurViews["\(msgCt)"] = [blur, tapMe]
        
                scrollView.addSubview(blur)
                scrollView.addSubview(tapMe)
            } else {
                //Purchase action
                let buttontext = "Tap here to unlock a second and more helpful hint.".localized()
                
                message2Height = heightForView(text: buttontext, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
                
                btn = UIButton(frame: CGRect(x: xRef + 10, y: titleLabel.frame.size.height + 5, width: alertView.frame.size.width - 20, height: message2Height!))
                btn.setTitle(buttontext, for: .normal)
                btn.titleLabel?.numberOfLines = 0
                btn.titleLabel?.font = UIFont(name: "Helvetica", size: 16.0)
                btn.titleLabel?.textAlignment = .center
                btn.setTitleColor(.blue, for: .normal)
                btn.addTarget(self, action: #selector(actionSheetForPurchase(_:)), for: .touchUpInside)
                scrollView.addSubview(btn)
            }
            
            controller?.view.bringSubviewToFront(tb!)
        }
    }
    
    func removeBlurView(index: String) {
        for i in blurViews["1"]! {
            i.removeFromSuperview()
        }
    }
    
    @objc func useHint() {
        let identifier = ProjectMayhemProducts.fiveHints
        var currentValue = game.integer(forKey: identifier)
        currentValue -= 1
        game.setValue(currentValue, forKey: identifier)
        removeBlurView(index: "1")
        var ref = Int.parse(from: dictRef)!
        if ref > 50 {
            ref = ref / 10
        }
        game.setValue(true, forKey: "hint\(ref)")
        message2Height = heightForView(text: tier2Hint[dictRef]!, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
        showTheMeat(xRef: alertView.frame.size.width, createBlur: false)
        showHint()
        stopAnimation(index: "1")
    }
    
    @objc func actionSheetForPurchase(_ sender: AnyObject) {
        print(sender)
        let bH = getIAP(productIdentifier: "com.YushRajKapoor.ProjectMayhem.betterHints")
        let fH = getIAP(productIdentifier: "com.YushRajKapoor.ProjectMayhem.FiveHints")
        let allPrice = bH.price
        let fivePrice = fH.price
        
        let actionSheet = UIAlertController(title: "Purchase hints".localized(),
                                            message: "Choose which hints you would like to purchase".localized(),
                                            preferredStyle: .actionSheet)
        
        let l1 = "All Hints".localized()
        let l2 = "Five Hints".localized()
        
        actionSheet.addAction(UIAlertAction(title: "\(l1) ($\(allPrice))", style: .default) { action in
            ProjectMayhemProducts.store.buyProduct(bH, funcTo: self.afterHint)
        })
        actionSheet.addAction(UIAlertAction(title: "\(l2) ($\(fivePrice))", style: .default) { action in
            ProjectMayhemProducts.store.buyProduct(fH, funcTo: self.afterHint)
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        if game.integer(forKey: "fivePackPurchaseCount") >= 3 {
            let p1 = "If you are seeing this, message me. This message should not appear.".localized()
            let p2 = "Error: Max Purchase Count".localized()
            let alertController = UIAlertController(title: "Error".localized(), message: "\(p1)\n\(p2)", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay".localized(), style: .default, handler: {_ in
                self.chat()
            })
            alertController.addAction(okay)
            self.controller!.present(alertController, animated: true, completion: nil)
        } else {
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.controller?.view
                popoverController.sourceRect = CGRect(x: (self.controller?.view.bounds.midX)!, y: (self.controller?.view.bounds.midY)!, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            controller!.present(actionSheet, animated: true)
        }
    }
    
    func afterHint() {
        btn.removeFromSuperview()
        checkIfPaywallRequired()
        bouncer(num: 1)
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
    
    
    @objc func chat() {
        rList.removeAll()
        
        goToChat(vc: controller!)
    }
    
    @objc func dismissAlert() {
        if menuState {
            menuState = false
            guard let hintButt = hint else {
                return
            }
            
            hintButt.rotate(rotation: -0.49999, duration: 0.5, option: [])
            UIView.animate(withDuration: 0.5, animations: {
                self.alertView.alpha = 0.0
                hintButt.tintColor = UIColor.systemYellow
                
            }, completion: { done in
                if done {
                    self.backgroundView.removeFromSuperview()
                    self.stopAllAnimations()
                }
            })
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        bounceAuto()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        bounceAuto()
    }
    
    func bounceAuto() {
        let pageNumber = round(scrollView.contentOffset.x / (scrollView.frame.size.width)*1)
        bouncer(num: pageNumber)
    }
    
    func bouncer(num: CGFloat) {
        var goTo:CGFloat = 0
        var msgHt:CGFloat = 0
        
        if num == 0 {
            goTo = 0
            msgHt = message1Height!
            d1.backgroundColor = .white
            d2.backgroundColor = .darkGray
        }
        else {
            goTo = alertView.frame.size.width
            msgHt = message2Height!
            d1.backgroundColor = .darkGray
            d2.backgroundColor = .white
        }
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: { [self] in
            self.scrollView.setContentOffset(CGPoint(x: goTo, y: 0), animated: true)
            button.frame = CGRect(x: alertView.frame.size.width / 4 - 37.5, y: msgHt + titleLabel.frame.size.height + 30, width: 75, height: 25)
            stuck.frame = CGRect(x: alertView.frame.size.width / 4 * 3 - 37.5, y: msgHt + titleLabel.frame.size.height + 30, width: 75, height: 25)
            alertView.frame = CGRect(x: 0, y: 0, width: alertView.frame.size.width, height: msgHt + titleLabel.frame.size.height + 70)
            d1.frame = CGRect(x: alertView.frame.size.width / 2 - 15, y: msgHt + titleLabel.frame.size.height + 15, width: 8, height: 8)
            d2.frame = CGRect(x: alertView.frame.size.width / 2 + 5, y: msgHt + titleLabel.frame.size.height + 15, width: 8, height: 8)
            alertView.center = (controller?.view.center)!
            gradient.frame = alertView.bounds
        })
    }
}

