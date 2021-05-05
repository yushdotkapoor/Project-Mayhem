//
//  speechModule.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/1/21.
//

import Foundation
import UIKit
import Speech

class speechModule:NSObject {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var active:String?
    private var rippler:UIView?
    private var targetStringArray: [String]?
    private var functionArray: [() -> Void]?
    
    convenience init(activeCode: String, rippleView:UIView) {
        self.init()
        active = activeCode
        rippler = rippleView
    }
    
    override init() {
        super.init()
    }
    
    func startRecording(target: [String]) {
        startRecording(target: target, arrayOfFunctions: [funcToPass!])
    }
    
    func startRecording(target: [String], arrayOfFunctions: [() -> Void]) {
        print("Speech Recognition Started")
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        targetStringArray = target
        functionArray = arrayOfFunctions
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                if game.string(forKey: "active") == "chap11" {
                    self.rippler!.rippleChap11(thisView: godThread!.view)
                }
                else {
                    self.rippler!.ripple()
                }
                let spokenContent = result?.bestTranscription.formattedString.lowercased()
                for (i, words) in target.enumerated() {
                    if spokenContent?.contains(words) == true {
                        impact(style: .heavy)
                        arrayOfFunctions[i]()
                    }
                    isFinal = (result?.isFinal)!
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 1)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                print("Speech Recognition Stopped")
                wait(time: 0.4, actions: {
                    if game.string(forKey: "active") == self.active && !(video?.isPlaying() ?? video?.isPlaying() != nil) && !self.isActive() {
                        print("Speech Recognition Activated again")
                        self.startRecording(target: target, arrayOfFunctions: arrayOfFunctions)
                    }
                })
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 1)
        
        inputNode.installTap(onBus: 1, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopRecording() {
        targetStringArray = []
        functionArray = []
        pause()
        print("audioEngine stopped")
    }
    
    func pause() {
        print("talk pause")
        audioEngine.inputNode.removeTap(onBus: 1)
        recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.stop()
    }
    
    func play() {
        print("talk play")
        startRecording(target: targetStringArray!, arrayOfFunctions: functionArray!)
    }
    
    func isActive() -> Bool {
        return audioEngine.isRunning
    }
    
    
    deinit {
        stopRecording()
    }
    
    
    
}
