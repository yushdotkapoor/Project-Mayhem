//
//  chapter3.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/25/20.
//

import UIKit

class chapter3: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var we: UILabel!
    @IBOutlet weak var I: UILabel!
    @IBOutlet weak var live: UILabel!
    
    var tapped1 = false
    var tapped2 = false
    var tapped3 = false
    var tapped4 = false
    
    var button1: UIButton! = nil
    var button2: UIButton! = nil
    var button3: UIButton! = nil
    var button4: UIButton! = nil
    
    override func viewDidLoad() {
           super.viewDidLoad()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        we.alpha = 0.0
        I.alpha = 0.0
        live.alpha = 0.0
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        createButtonsForPart2()
        createButtonsForPart1()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        game.setValue("chap2", forKey: "active")
        
    }
    
    func part1() {
        game.setValue("chap2.1", forKey: "active")
        UIView.animate(withDuration: 1.0, delay: 0, animations: {
            self.button1.frame.origin = CGPoint(x: 50, y: self.I.frame.origin.y + 210.5)
            
            self.button2.frame.origin = CGPoint(x: self.view.bounds.width - 161, y: self.I.frame.origin.y + 70.5)
            
        }, completion: { _ in
            self.tapReset()
            self.button3.tintColor = UIColor.black
            self.button4.tintColor = UIColor.black
            
                UIView.animate(withDuration: 1.0) {
                    self.button3.frame.origin.y += 140
                    self.button4.frame.origin.y -= 140
                
                }
        })
        
    }
    
    func part2() {
        game.setValue("chap2.2", forKey: "active")
        UIView.animate(withDuration: 1.0, delay: 0, animations: {
            self.button1.frame.origin.x = (self.view.bounds.width / 2) - 50
            self.button2.frame.origin.x = (self.view.bounds.width / 2) - 50
            self.button3.frame.origin.y -= 70
            self.button4.frame.origin.y += 70
            
            
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 0, animations: {
                self.button1.frame.origin.y -= self.view.bounds.height
                self.button2.frame.origin.y += self.view.bounds.height
                self.button3.frame.origin.x -= self.view.bounds.width
                self.button4.frame.origin.x += self.view.bounds.width
                
            }, completion: { _ in
                self.we.flickerIn()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.we.fadeOut()
                    self.I.flickerIn()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.live.flickerIn()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.I.fadeOut()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                self.complete()
                            }
                        }
                    }
                    
                }
            })
            
        })
        
        
        
    }
    
    func complete() {
        game.setValue(true, forKey: "chap3")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    func createButtonsForPart2() {
         button3 = UIButton(frame: CGRect(x: self.view.bounds.width - 161, y: self.I.frame.origin.y + 70.5, width: 100, height: 100))
        button3.setBackgroundImage(UIImage(systemName: "circle.fill"), for: .normal)
        button3.tintColor = UIColor.white
        button3.addTarget(self, action: #selector(button3TouchUpInside), for: .touchUpInside)
        button3.addTarget(self, action: #selector(button3TouchDown), for: .touchDown)
        
        button4 = UIButton(frame: CGRect(x: 50, y: self.I.frame.origin.y + 210.5, width: 100, height: 100))
        button4.setBackgroundImage(UIImage(systemName: "circle.fill"), for: .normal)
        button4.tintColor = UIColor.white
        button4.addTarget(self, action: #selector(button4TouchUpInside), for: .touchUpInside)
        button4.addTarget(self, action: #selector(button4TouchDown), for: .touchDown)

        self.view.addSubview(button3)
        self.view.addSubview(button4)
    }
    
    func createButtonsForPart1() {
         button1 = UIButton(frame: CGRect(x: self.view.bounds.width - 161, y: self.I.frame.origin.y + 70.5, width: 100, height: 100))
        button1.setBackgroundImage(UIImage(systemName: "circle.fill"), for: .normal)
        button1.tintColor = UIColor.black
        button1.addTarget(self, action: #selector(button1TouchUpInside), for: .touchUpInside)
        button1.addTarget(self, action: #selector(button1TouchDown), for: .touchDown)
        
        button2 = UIButton(frame: CGRect(x: 50, y: self.I.frame.origin.y + 210.5, width: 100, height: 100))
        button2.setBackgroundImage(UIImage(systemName: "circle.fill"), for: .normal)
        button2.tintColor = UIColor.black
        button2.addTarget(self, action: #selector(button2TouchUpInside), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2TouchDown), for: .touchDown)

        self.view.addSubview(button1)
        self.view.addSubview(button2)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "chap3ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap3ToChap4", sender: nil)
    }
    
    
    @objc func button1TouchUpInside(_ sender: Any) {
        tapped1 = false
    }
    
    @objc func button1TouchDown(_ sender: Any) {
        tapped1 = true
        tapCheck()
    }
    
    @objc func button2TouchUpInside(_ sender: Any) {
        tapped2 = false
    }
    
    @objc func button2TouchDown(_ sender: Any) {
        tapped2 = true
        tapCheck()
    }
    
    @objc func button3TouchUpInside(sender: UIButton!) {
        tapped3 = false
    }
    
    @objc func button3TouchDown(sender: UIButton!) {
        tapped3 = true
        tapCheck2()
    }
    
    @objc func button4TouchUpInside(sender: UIButton!) {
        tapped4 = false
    }
    
    @objc func button4TouchDown(sender: UIButton!) {
        tapped4 = true
        tapCheck2()
    }
    
    func tapCheck() {
        let active = game.string(forKey: "active")
        if tapped1 && tapped2 && active == "chap2"  {
            part1()
        }
    }
    
    func tapCheck2() {
        let active = game.string(forKey: "active")
        if tapped1 && tapped2 && tapped3 && tapped4 && active == "chap2.1" {
            part2()
        }
    }
    
    func tapReset() {
        tapped1 = false
        tapped2 = false
        tapped3 = false
        tapped4 = false
    }


}
