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
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var rippleCircle: UIImageView!
    
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
        setImage()
        label.alpha = 0.0
        game.setValue("chap11", forKey: "active")
        startRecording()
    }
    
    func setImage() {
        logo.layer.borderWidth = 1
        logo.layer.borderColor = UIColor.white.cgColor
        logo.layer.cornerRadius = 20
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
                if ((result?.bestTranscription.formattedString.lowercased().contains("project mayhem")) == true) || ((result?.bestTranscription.formattedString.lowercased().contains("project mayham")) == true) {
                    self.label.text = "Project Mayhem"
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
}
