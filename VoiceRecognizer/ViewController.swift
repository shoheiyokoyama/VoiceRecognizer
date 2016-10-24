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
    private let recognizer: VoiceRecognizer = .init(sourceNames: ["v1.m4a", "v2.m4a", "v3.m4a", "v4.m4a", "v5.m4a"], taskName: "task")

    // MARK: - Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizer.delegate = self
    }
    
    @IBAction func tappedButton(_ sender: AnyObject) {
        recognizer.startRecordining()
        button.isEnabled = false
    }
}

// MARK: - RecognizerDelegate

extension ViewController: RecognizerDelegate {
    func recognizer(_ recognizer: VoiceRecognizer, didRecognizing fileName: String) {
        titileLabel.text = "Processing: \(fileName)"
    }
}
