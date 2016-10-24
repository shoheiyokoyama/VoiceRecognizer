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
    
    @IBOutlet private weak var button: UIButton!
    private var recognizer: VoiceRecognizer?

    // MARK: - Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sourceFiles = ["movie1.m4a", "movie2.m4a", "movie3.m4a"]
        
        // example
        
//        let filename = "サントリー動画"
//        let sourceFiles = (0..<24).enumerated().map { index in
//            return filename + "-" + "\(index.element + 1)" + ".m4a"
//        }
        
        recognizer = VoiceRecognizer(sourceNames: sourceFiles, taskName: "サントリー")
        recognizer?.delegate = self
    }
    
    @IBAction func tappedButton(_ sender: AnyObject) {
        recognizer?.startRecordining()
        button.isEnabled = false
    }
}

// MARK: - RecognizerDelegate

extension ViewController: RecognizerDelegate {
    func recognizer(_ recognizer: VoiceRecognizer, didRecognizing fileName: String) {
        titileLabel.text = "Processing: \(fileName)"
    }
}
