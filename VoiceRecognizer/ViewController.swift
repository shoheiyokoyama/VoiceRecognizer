//
//  ViewController.swift
//  VoiceRecognizer
//
//  Created by Shohei Yokoyama on 2016/09/24.
//  Copyright © 2016年 Shohei. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet fileprivate weak var titileLabel: UILabel!
    @IBOutlet fileprivate weak var button: UIButton!
    
    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    fileprivate var recognitionRequest: SFSpeechURLRecognitionRequest?
    
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    fileprivate let audioType = "m4a"
    
    fileprivate let voiceFileNames: [String] = ["v1", "v2", "v3", "v4", "v5"]
    
    fileprivate var result = ""
    
    fileprivate var longestContents = ""
    
    fileprivate var currentIndex = 0 {
        didSet {
            longestContents = ""
        }
    }
    
    // MARK: - Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.isEnabled = false
    }
    
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
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self?.button.isEnabled = true
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
        button.isEnabled = false
    }
    
    func startRecording() throws {
        guard speechRecognizer.isAvailable else { return }
        titileLabel.text = "Processing..."
        button.setTitle("Processing...", for: .normal)
        recognize(index: 0)
    }
    
    func recognize(index: Int) {
        if index + 1 > voiceFileNames.count {
            complete()
            return
        }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        guard let audioPath = Bundle.main.path(forResource: voiceFileNames[index], ofType: audioType) else {
            fatalError("Unable to created audioPath \(voiceFileNames[index])")
        }
        
        titileLabel.text = "Processing " + voiceFileNames[index] + "." + audioType
        recognitionRequest = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: audioPath))
        
        recognize { [weak self] in
            guard let me = self else { return }
            me.currentIndex = index + 1
            me.recognize(index: me.currentIndex)
        }
    }
    
    func recognize(completion: @escaping () -> ()) {
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // for SFSpeechRecognitionTaskDelegate
        // recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)
        
        // for Success Request
        sleep(5)
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let me = self, let result = result, error == nil else {
                print(error, self?.currentIndex)
                self?.recognize(index: (self?.currentIndex)!)
                return
            }
            
            let text = result.bestTranscription.formattedString
            
            if me.longestContents.characters.count <= text.characters.count {
                me.longestContents = text
            }
            
            if result.isFinal {
                me.result.append("\(me.currentIndex): " + me.longestContents + "\n")
                print("\(me.currentIndex): " + me.longestContents + "\n")
                completion()
            }
        }
    }
    
    func complete() {
        titileLabel.text = "Voice Recognizer"
        button.setTitle("Finish Recognizeing", for: .normal)
        button.isEnabled = true
        print("======== Finish Recognizeing =========")
        print(result)
        saveFile()
    }
    
    func saveFile() {

        let fileName = "recognize" + ".txt"

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = documentsPath + "/" + fileName
        
        do {
            try result.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf16)
            print("======== Success Write file =========")
        } catch {
            print("error")
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
