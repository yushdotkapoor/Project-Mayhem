//
//  chapter11.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit
import Speech

class chapter11: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rippleCircle: UIImageView!
    @IBOutlet weak var morseText: UILabel!
    @IBOutlet weak var binaryText: UILabel!
    @IBOutlet weak var pigpenCipherText: UILabel!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    
    var resetInProgress = false
    var currentString = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
           super.viewDidLoad()
        resetInProgress = false
        currentString = ""
        label.alpha = 0.0
        binaryText.text = binaryText.text?.stringToBinary()
        morseText.text = morseText.text?.stringToMorse()
        game.setValue("chap11", forKey: "active")
        startRecording()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func complete() {
        game.setValue(true, forKey: "chap11")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }

    @IBAction func goBack(_ sender: Any) {
        stopRecording()
        self.performSegue(withIdentifier: "chap11ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap11ToChap12", sender: nil)
    }
    
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
           
            var isFinal = false
            
            if result != nil {
                self.rippleCircle.ripple(view: self.view)
                if ((result?.bestTranscription.formattedString.lowercased().contains("william shakespeare")) == true) {
                    self.label.text = "William Shakespeare"
                    self.pigpenCipherText.fadeOut()
                    self.morseText.fadeOut()
                    self.binaryText.fadeOut()
                    self.label.fadeIn()
                    self.stopRecording()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.complete()
                    }
                }
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                if game.string(forKey: "active") == "chap11" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.startRecording()
                    }
                }
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        label.text = ""
        
    }
    
    func stopRecording() {
        game.setValue("none", forKey: "active")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    deinit {
        stopRecording()
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
            customAlert.showAlert(message: "Who wrote this?", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
}
