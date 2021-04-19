//
//  HintAlert.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/13/21.
//

import UIKit

class HintAlert: NSObject, UIScrollViewDelegate {
    
    private let backgroundView:UIView = UIView()
    
    private var hint:UIButton?
    
    private var msgCt = 0
    
    var tier1Hint = ["1":"Leave what?", "2":"How could you make sure that you can hear everything?","3":"Tappity tap","4":"Move your phone a bit. Just kidding, a lot.","5":"do re mi fa so laaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n\nAlso, Nice ;)","6":"Seems like this is a coded message!\n\nNote: Make sure your system haptics are turned on.\n\nAlso, don't curse in a castle, it's bad for our reputation.","7":"Rule number 1: have patience. Rule number 2: have good memory skills. Rule number 3: see what happens when you tap (r1,c2).","8":"What's that on the top right?","9":"These are not just some random characters! Have you ever heard of 🐷🖊️ Cipher?","10":"I wonder what I could do with a QR code, once it is aligned","11.1":"Maybe the morse code at the top and the coordinates at the bottom have some sort of relationship.","11.2":"Great works from a great man, who indeed has a name!","12.1": "Battery, battery, battery. It bugs me that the battery isn't completely full", "12.2":"Roses are red, violets are blue, I'm pretty sure that this is a date. What are you supposed to do? \"Get in a blue box and get your timey wimey on.\"","12.3":"Is there a way to change the size of text?","13.1":"Dude c'mon. The text on the screen IS the hint","13.2":"Earthquake simulator?","13.3":"Earthquake simulator?: Look for the red","14": "\"As the Curtain Rose, the people cheered and the bootleggers took Pictures.\"","15.1":"The color white is the --- of the color black. That's pretty smart.","15.2":"The answer is not in this level. Look closely 👁️"]
    
    var tier2Hint = ["1":"Maybe it's best if you go home.", "2":"If you were on the phone and could not hear the other person on speaker, what would you do?","3":"Tap the little circles simultaneously.","4":"Stright lines, fast movements, phone flat.","5":"\"A\" is known as a musical note and has different pitches. Remember, nothing is off limits!","6":"Morse code, isn't it? Let's see what the internet can do for you.","7":"I suggest writing down a grid and tapping around to see what happens.","8":"I wonder what happens if we look for the app settings?","9":"Use your resources to decode this message","10":"Scan the QR code and see what pops up.","11.1":"The coordinates at the bottom correspond to the location of a character in the letter. The second part to the morse code is as follows: ----graph, ----ence, ----acter.\n","11.2":"Say the name of the playright!","12.1": "Let's fill that battery.", "12.2":"Maybe we can travel back in time.","12.3":"It's possible that there is a setting to change the general size of fonts?","13.1":"You gotta physically move back","13.2":"Let's undo.","13.3":"Let's keep undoing and see what the red letters spell out.","14": "-(swipe*(-right)*down)/right","15.1":"inverse","15.2":"There are 15 hidden letters in the levels prior."]
    
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
        lbl.text = "Hint"
        lbl.font = lbl.font.withSize(25)
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    
    private var d1 = UIView()
    private var d2 = UIView()
    
    private let button = CustomButtonOutline()
    
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
    
    
    func showAlert(message: String, viewController: UIViewController, hintButton: UIButton, toolbar: UIStackView) {
        hint = hintButton
        controller = viewController
        reqProducts()
        dictRef = message
        tb = toolbar
        
        let alertController = UIAlertController(title: "Are you sure?", message: "Are you sure you would like to see a hint?", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .default, handler: {_ in
            self.dismissAlert()
        })
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.okActuallyShowTheHint(hintButton: hintButton)
        })
        alertController.addAction(no)
        alertController.addAction(yes)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func okActuallyShowTheHint(hintButton: UIButton) {
        guard let targetView = controller?.view else {
            return
        }
        msgCt = 0
        backgroundView.frame = targetView.frame
        targetView.addSubview(backgroundView)
        
        alertView.isUserInteractionEnabled = true
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: 100)
        alertView.isHidden = true
        alertView.alpha = 0.0
        
        message1Height = heightForView(text: self.tier1Hint[dictRef]!, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
        message2Height = heightForView(text: self.tier2Hint[dictRef]!, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
        
        let titleLabelHeight = heightForView(text: "Hint", font: UIFont(name: "Helvetica", size: 25.0)!, width: alertView.frame.size.width - 10)
        //create a title label
        titleLabel.frame = CGRect(x: 5, y: 5, width: alertView.frame.size.width - 10, height: titleLabelHeight)
        
        //set up scrollView
        scrollView.contentSize = CGSize(width: alertView.frame.size.width*2, height: alertView.frame.size.height)
        scrollView.delegate = self
        
        //set up button
        button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: message1Height! + titleLabelHeight + 55, width: 75, height: 25)
        button.setupButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        
        //set up dot stack
        d1 = UIView(frame: CGRect(x: alertView.frame.size.width / 2 - 15, y: message1Height! + titleLabelHeight + 15, width: 8, height: 8))
        d1.layer.cornerRadius = 4
        d2 = UIView(frame: CGRect(x: alertView.frame.size.width / 2 + 5, y: message1Height! + titleLabelHeight + 15, width: 8, height: 8))
        d2.layer.cornerRadius = 4
        
        
        //resize alertView
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: message1Height! + titleLabel.frame.size.height + 95)
        alertView.center = targetView.center
        gradient.colors = [UIColor(named: "MayhemBlue")!.cgColor, UIColor(named: "MayhemGray")!.cgColor]
        gradient.frame = alertView.bounds
        alertView.layer.addSublayer(gradient)
        targetView.addSubview(alertView)
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapExit))
        tap.numberOfTapsRequired = 1
        backgroundView.addGestureRecognizer(tap)
    }
    
    func showTheMeat(xRef:CGFloat) {
        var text = tier1Hint[dictRef]
        var msgHt:CGFloat = 0
        
        if msgCt == 0 {
            msgHt = message1Height!
            alertView.addSubview(scrollView)
            alertView.addSubview(button)
            
        }
        else if msgCt == 1 {
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
        
        scrollView.addSubview(messageLabel)
        
        msgCt += 1
        
        if msgCt == 1 {
            checkIfPaywallRequired()
        }
        else if msgCt == 2 {
            controller?.view.bringSubviewToFront(tb!)
        }
    }
    
    func checkIfPaywallRequired() {
        let xRef = alertView.frame.size.width
        if ProjectMayhemProducts.store.isProductPurchased(ProjectMayhemProducts.hints) {
            showTheMeat(xRef: xRef)
        }
        else {
            let buttontext = "Tap here to unlock a second and more helpful hint for every level."
            
            message2Height = heightForView(text: buttontext, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertView.frame.size.width - 20)
            
            let btn = UIButton(frame: CGRect(x: xRef + 10, y: titleLabel.frame.size.height + 5, width: alertView.frame.size.width - 20, height: message2Height!))
            btn.setTitle(buttontext, for: .normal)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.font = UIFont(name: "Helvetica", size: 16.0)
            btn.titleLabel?.textAlignment = .center
            btn.setTitleColor(.blue, for: .normal)
            btn.addTarget(self, action: #selector(makePurchase), for: .touchUpInside)
            
            scrollView.addSubview(btn)
            controller?.view.bringSubviewToFront(tb!)
        }
    }
    
    @objc func makePurchase() {
        for i in IAPs ?? [] {
            if i.productIdentifier == "com.YushRajKapoor.ProjectMayhem.betterHints"{
                ProjectMayhemProducts.store.buyProduct(i)
            }
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
    
    @objc func dismissAlert() {
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
                self.alertView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        })
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
            button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: msgHt + titleLabel.frame.size.height + 30, width: 75, height: 25)
            alertView.frame = CGRect(x: 0, y: 0, width: alertView.frame.size.width, height: msgHt + titleLabel.frame.size.height + 70)
            d1.frame = CGRect(x: alertView.frame.size.width / 2 - 15, y: msgHt + titleLabel.frame.size.height + 15, width: 8, height: 8)
            d2.frame = CGRect(x: alertView.frame.size.width / 2 + 5, y: msgHt + titleLabel.frame.size.height + 15, width: 8, height: 8)
            alertView.center = (controller?.view.center)!
            gradient.frame = alertView.bounds
        })
    }
}

