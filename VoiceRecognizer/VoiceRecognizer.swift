//
//  VoiceRecognizer.swift
//  VoiceRecognizer
//
//  Created by Shohei Yokoyama on 2016/10/24.
//  Copyright © 2016年 Shohei. All rights reserved.
//

import UIKit
import Speech

// MARK : - RecognizerDelegate -

@objc protocol RecognizerDelegate: class {
    @objc optional func recognizer(_ recognizer: VoiceRecognizer, didRecognizing fileName: String)
}

// MARK : - VoiceRecognizer -

final class VoiceRecognizer: NSObject {
    
    var isOutputLongestresult = true
    weak var delegate: RecognizerDelegate?
    
    // Fileprivate properties
    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    fileprivate var recognitionRequest: SFSpeechURLRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    fileprivate var sourceNames: [String] = []
    fileprivate var result = ""
    fileprivate var longestResult = ""
    fileprivate var taskName = ""
    
    // MARK: - Initializer
    
    convenience init(sourceNames: [String] = [], taskName: String = "") {
        self.init()
        
        self.sourceNames = sourceNames
        self.taskName = taskName
        speechRecognizer.delegate = self
    }
    
    func startRecordining() {
        guard speechRecognizer.isAvailable else { return }
        recognize()
    }
}

// MARK: - Private Methods

private extension VoiceRecognizer {
    func confirmAuthorization () {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:    print("Speech recognition OK")
                case .denied:        print("User denied access to speech recognition")
                case .restricted:    print("Speech recognition restricted on this device")
                case .notDetermined: print("Speech recognition not yet authorized")
                }
            }
        }
    }
    
    func recognize(ofIndex index: Int = 0) {
        if index >= sourceNames.count {
            completeRecognizing()
            return
        }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let separatedFileNames = sourceNames[index].components(separatedBy: ".")
        guard let audioPath = Bundle.main.path(forResource: separatedFileNames.first, ofType: separatedFileNames[1]) else {
            fatalError("Unable to created audioPath \(sourceNames[index])")
        }
        
        recognitionRequest = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: audioPath))
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // for SFSpeechRecognitionTaskDelegate
        // recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)
        
        // for Success Request
        sleep(5)
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let me = self else { return }
            guard let result = result, error == nil else {
                print("Error: \(error), Filename: \(me.sourceNames[index])")
                me.recognize(ofIndex: index)
                return
            }
            
            let text = result.bestTranscription.formattedString
            
            if me.isOutputLongestresult && me.longestResult.characters.count <= text.characters.count {
                me.longestResult = text
            }
            
            if result.isFinal {
                print("\(me.sourceNames[index]): " + (me.isOutputLongestresult ? me.longestResult : text) + "\n")
                me.result.append("\(me.sourceNames[index]): " + (me.isOutputLongestresult ? me.longestResult : text) + "\n")
                me.longestResult = ""
                me.recognize(ofIndex: index + 1)
            }
        }
        
        print("Start Recognizeing: \(sourceNames[index])")
        delegate?.recognizer?(self, didRecognizing: sourceNames[index])
    }
    
    func completeRecognizing() {
        print("Finish Recognizeing \n \(result)")
        writeToFile()
    }
    
    func writeToFile() {
        let today: Date = .init()
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "YYYYMMdd"
        let dateString = formatter.string(from: today)
        
        let fileName = dateString + "-" + taskName + ".txt"
        
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            print("Failure getting documentsPath")
            return
        }
        
        let filePath = documentsPath + "/" + fileName
        
        do {
            try result.write(toFile: filePath, atomically: true, encoding: .utf16)
        } catch {
            print("error")
        }
    }
}

// MARK: - SFSpeechRecognitionTaskDelegate -

extension VoiceRecognizer: SFSpeechRecognitionTaskDelegate {
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("didFinishSuccessfully: \(successfully)")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print(transcription.formattedString)
    }
}

// MARK: - SFSpeechRecognizerDelegate -

extension VoiceRecognizer: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Start Recording")
        } else {
            print("Recognition not available")
        }
    }
}
