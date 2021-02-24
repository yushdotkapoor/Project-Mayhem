//
//  UIViewControllerExtensions.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/29/21.
//

import UIKit
import AVKit

extension UIViewController {

    func alert(title: String, message: String, actionTitle: String) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String, actionTitle: String, actions: @escaping () -> Void) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: { action in actions()})
        
        alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        //label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.font = label.font.withSize(font.pointSize + 1)
        label.text = text

        label.sizeToFit()
        return label.frame.height
   }
    
    func vibrate(count: Int) {
        if count != 0 {
            impact(style: .medium)
            wait(time: 0.1, actions: {
                self.vibrate(count: count - 1)
            })
        }
    }
    
    func playLocalVideo(name: String, type: String, playView: PlayerView, array: [Double]) -> VideoPlayer {
        if let filePath = Bundle.main.path(forResource: name, ofType: type) {
            let fileURL = NSURL(fileURLWithPath: filePath)
            return VideoPlayer(urlAsset: fileURL, view: playView, arr: array)
        }
        return VideoPlayer()
    }
    
    
}
