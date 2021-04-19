//
//  subPostChapter15.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/24/21.
//

import UIKit
import AVKit
import Speech

class subPostChapter15: UIViewController {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var doubleTapInstructions: UILabel!
    @IBOutlet weak var back: UIButton!
    
    let pauseArray:[Double] = [9, 15, 38.5, 61.9, 64.5, 70.3, 107]
    
    var timeStamp:Double = 0.0
    
    var vidName:String = "subPostChapter15"
    
    var speakLabels:[CustomButtonOutline] = []
    
    var status = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.setValue("subPostChap15", forKey: "active")
        ripplingView = back
        
        funcToPass = part1
        godThread = self
        video = VideoPlayer(urlAsset: vidName, view: playerView, arr: pauseArray, startTime: 0, volume: 0.1)
        talk = speechModule(activeCode: game.string(forKey: "active")!, rippleView: ripplingView!)
        
        tomorrow = UIFont(name: "Tomorrow", size: 20)
        
        flashInstructions()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    func part1() {
        wordToSearch = ["what are you doing here"]
        let button = createLabel(text: "What are you doing here?", callBack: #selector(postPart1))
        speakLabels = [button]
        for i in speakLabels {
            i.fadeIn()
        }
        funcToPass = postPart1
        talk?.startRecording(target: wordToSearch!)
    }
    
    @objc func postPart1() {
        for i in speakLabels {
            i.fadeOut()
        }
        wait {
            self.speakLabels.removeAll()
        }
        talk?.pause()
        funcToPass = part2
        video?.play()
        print("postPart1")
    }
    
    func part2() {
        print("part2")
        let arr = ["what do you want"]
        wordToSearch = arr
        let button = createLabel(text: "What do you want?", callBack: #selector(postPart2))
        speakLabels = [button]
        for i in speakLabels {
            i.fadeIn()
        }
        funcToPass = postPart2
        talk?.startRecording(target: wordToSearch!)
    }
    
    @objc func postPart2() {
        print("postPart2")
        for i in speakLabels {
            i.fadeOut()
        }
        wait {
            self.speakLabels.removeAll()
        }
        talk?.pause()
        funcToPass = part3
        video?.play()
    }
    
    func part3() {
        print("part3")
        let arr = ["see for yourself"]
        wordToSearch = arr
        let button = createLabel(text: "See for yourself.", callBack: #selector(postPart3))
        speakLabels = [button]
        for i in speakLabels {
            i.fadeIn()
        }
        funcToPass = postPart3
        talk?.startRecording(target: wordToSearch!)
    }
    
    @objc func postPart3() {
        print("postPart3")
        for i in speakLabels {
            i.fadeOut()
        }
        wait {
            self.speakLabels.removeAll()
        }
        talk?.pause()
        funcToPass = part4
        video?.play()
    }
    
    func part4() {
        print("part4")
        let arr = ["what does it say", "how did you know that was there"]
        wordToSearch = arr
        let button = createLabel(text: "What does it say?", callBack: #selector(postPart4_1))
        speakLabels = [button]
        let button2 = createLabel(text: "How did you know that was there?", callBack: #selector(postPart4_2))
        speakLabels.append(button2)
        for i in speakLabels {
            i.fadeIn()
        }
        funcToPass = postPart4_1
        talk?.startRecording(target: wordToSearch!, arrayOfFunctions: [postPart4_1, postPart4_2])
    }
    
    @objc func postPart4_1() {
        print("postPart4_1")
        for i in speakLabels {
            i.fadeOut()
        }
        wait(time: 0.5, actions: {
            self.speakLabels.removeAll()
        })
        talk?.pause()
        funcToPass = bypass4
        video?.play()
    }
    
    func bypass4() {
        print("bypass4")
        funcToPass = part5
        if let player = video?.assetPlayer {
            if let timeScale = player.currentItem?.asset.duration.timescale {
                
                player.seek(to: CMTimeMakeWithSeconds(70.25, preferredTimescale: timeScale), toleranceBefore: CMTimeMakeWithSeconds(0.05, preferredTimescale: timeScale), toleranceAfter: CMTimeMakeWithSeconds(0.05, preferredTimescale: timeScale), completionHandler: { (complete) in
                    self.part5()
                })
            }
        }
    }
    
    @objc func postPart4_2() {
        print("postPart4_2")
        for i in speakLabels {
            i.fadeOut()
        }
        wait {
            self.speakLabels.removeAll()
        }
        talk?.pause()
        funcToPass = part5
        if let player = video?.assetPlayer {
            if let timeScale = player.currentItem?.asset.duration.timescale {
                player.seek(to: CMTimeMakeWithSeconds(65, preferredTimescale: timeScale), completionHandler: { (complete) in
                    video?.play()
                })
            }
        }
    }
    
    func part5() {
        print("part5")
        let arr = ["why are you doing this"]
        wordToSearch = arr
        let button = createLabel(text: "Why are you doing this?", callBack: #selector(postPart5))
        speakLabels = [button]
        for i in speakLabels {
            i.fadeIn()
        }
        funcToPass = postPart5
        talk?.startRecording(target: wordToSearch!)
    }
    
    @objc func postPart5() {
        print("postPart5")
        for i in speakLabels {
            i.fadeOut()
        }
        wait {
            self.speakLabels.removeAll()
        }
        talk?.pause()
        funcToPass = end
        video?.play()
    }
    
    func end() {
        print("end")
        video?.cleanUp()
        talk?.stopRecording()
        NotificationCenter.default.removeObserver(godThread!)
        game.setValue(true, forKey: "subPostChapter15Watched")
        game.setValue("none", forKey: "active")
        godThread?.performSegue(withIdentifier: "subPostChap15ToPostChap15", sender: nil)
    }
    
    func createLabel(text: String, callBack: Selector) -> CustomButtonOutline {
        let labelWidth = UIScreen.main.bounds.size.width - 20
        let titleLabelHeight = heightForView(text: text, font: tomorrow ?? .systemFont(ofSize: 25) , width: labelWidth)
        var heightsBefore:CGFloat = 0
        for i in speakLabels {
            heightsBefore += i.frame.height + 20
        }
        
        let frame = CGRect(x: 10, y: UIScreen.main.bounds.size.height - 150 - heightsBefore - titleLabelHeight, width: labelWidth, height: titleLabelHeight + 10)
        
        let button = CustomButtonOutline(frame: frame)
        button.setupButton(color: .green)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.frame = CGRect(x: 15, y: 0, width: (button.titleLabel?.frame.size.width)! - 30, height: (button.titleLabel?.frame.size.height)!)
        button.titleLabel?.font = tomorrow
        button.alpha = 0.0
        button.addTarget(self, action: callBack, for: .touchUpInside)
        
        //Just for this specific implementation!
        button.isUserInteractionEnabled = false
        
        view.addSubview(button)
        
        return button
    }
    
    func flashInstructions() {
        let t = game.bool(forKey: "subPostChapter15Watched")
        video?.startFlash(lbl: doubleTapInstructions, chap: ["subPostChap15"], willFlash: t)
    }
    
    @objc func doubleTapped() {
        let t = game.bool(forKey: "subPostChapter15Watched")
        video?.viewDidDoubleTap(willPass: t)
    }
    
    @objc func background() {
        timeStamp = video!.currentTime
        if video!.isPlaying() {
            print("background video")
            status = "video"
            video?.pause()
        }
        else {
            print("background talk")
            status = "talk"
            video?.functionCalled = true
            talk?.pause()
        }
        game.setValue("none", forKey: "active")
        video?.stopFlashing(lbl: doubleTapInstructions)
    }
    
    @objc func reenter() {
        game.setValue("subPostChap15", forKey: "active")
        
        if timeStamp - 2 < 0 {
            timeStamp = 2
        }
        
        if status == "talk" {
            print("reenter talk")
            talk?.play()
            video?.functionBlock()
        }
        else {
            print("reenter video")
            video?.play()
        }
        
        flashInstructions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        hint.alpha = 0.0
        hint.isUserInteractionEnabled = false
        doubleTapInstructions.alpha = 0.0
    }
    
    func stop() {
        video?.cleanUp()
        talk?.stopRecording()
        godThread = nil
        game.setValue("none", forKey: "active")
    }
    
    @IBAction func back(_ sender: Any) {
        stop()
        NotificationCenter.default.removeObserver(self)
        performSegue(withIdentifier: "subPostChap15ToHome", sender: self)
    }
    
}
