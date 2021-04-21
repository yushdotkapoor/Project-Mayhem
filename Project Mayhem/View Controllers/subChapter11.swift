//
//  subChapter11.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/18/21.
//

import UIKit
import AVKit

class subChapter11: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var textField: nonPastableTextField!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var textFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var customAlert = HintAlert()
    
    var keyboardAdded: CGFloat = 0.0
    var open = false
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.alpha = 0.3
        
        nextChap.isUserInteractionEnabled = false
        nextChap.alpha = 0.0
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        imageView.image = UIImage(named: "MtgTranscript")
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 1
        view.bringSubviewToFront(toolbar)
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if open {
            return
        }
        textField.alpha = 1.0
        let bounds = UIScreen.main.bounds
        let deviceHeight = bounds.size.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let labelHeight = deviceHeight - textStack.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
            textFieldConstraint.constant += add
            open = true
        }
    }
    
    @objc func keyboardWillHide() {
        textField.alpha = 0.3
        textFieldConstraint.constant -= keyboardAdded
        open = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alert.showAlert(title: "Message from Victoria Lambson", message: "You might want to see this.", viewController: self, buttonPush: #selector(dismissMessageAlert))
    }
    
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        //add code if needed
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            scrollView.isScrollEnabled = true
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.width
                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        }
        else {
            scrollView.contentInset = .zero
            scrollView.isScrollEnabled = false
            imageView.frame = scrollView.bounds
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "subChap11ToHome", sender: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        let text = textField.text
        
        if text == "" {
            return
        }
        
        if text?.lowercased() == "murder" {
            vibrate(count: 5)
            view.endEditing(true)
            textField.textColor = .green
            textStack.isUserInteractionEnabled = false
            NotificationCenter.default.removeObserver(self)
            hint.isUserInteractionEnabled = false
            wait {
                self.textStack.flickerOut()
                wait {
                    self.performSegue(withIdentifier: "subChap11ToChap11", sender: nil)
                }
            }
        }
        else {
            textField.shake()
            textField.text = ""
            impact(style: .light)
            
        }
        
        
    }
    
    
    
    @IBAction func hint(_ sender: Any) {
        if menuState {
            //if menu open and want to close
            dismissAlert()
        }
        else {
            menuState = true
            //if menu closed and want to open
            hint.rotate(rotation: 0.49999, duration: 0.5, option: [])
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert = HintAlert()
            customAlert.showAlert(message: "11.1", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
}
