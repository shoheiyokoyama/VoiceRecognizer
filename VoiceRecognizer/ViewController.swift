//
//  ViewController.swift
//  VoiceRecognizer
//
//  Created by 横山祥平 on 2016/09/24.
//  Copyright © 2016年 Shohei. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    fileprivate var recognitionRequest: SFSpeechURLRecognitionRequest?
    
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    fileprivate let audioType = "m4a"
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configure()
        confirmAuthorization()
    }
}

// MARK: - fileprivate Methods -

fileprivate extension ViewController {
    func configure() {
        speechRecognizer.delegate = self
    }
    
    func confirmAuthorization () {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("speech recognition OK")
                    
                case .denied:
                    print("User denied access to speech recognition")
                    
                case .restricted:
                    print("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                }
            }
        }
    }
    
    @IBAction func tappedButton(_ sender: AnyObject) {
        try! startRecording()
    }
    
    func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        guard speechRecognizer.isAvailable else { return }
        
        let audioPath = Bundle.main.path(forResource: "voice", ofType: audioType)!
        recognitionRequest = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: audioPath))
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // for SFSpeechRecognitionTaskDelegate
        // recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            guard let result = result, error == nil else { return }
            
            if result.isFinal {
                let text = result.bestTranscription.formattedString
                print(text)
            }
        }
    }
}

// MARK: - SFSpeechRecognitionTaskDelegate -

extension ViewController: SFSpeechRecognitionTaskDelegate {
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print(successfully)
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        let text = transcription.formattedString
        print(text)
    }
}

// MARK: - SFSpeechRecognizerDelegate -

extension ViewController: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Start Recording")
        } else {
            print("Recognition not available")
        }
    }
}
