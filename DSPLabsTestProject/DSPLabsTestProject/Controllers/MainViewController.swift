//
//  MainViewController.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 20.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UITabBarController {
    
    private var audioSession: AVAudioSession!
    private var isSplashWasShown = false
    
    // Hold portrait orientation
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataPath = getDataDirectory()
        do {
            try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            showAlert(withMessage: error.localizedDescription)
        }

        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { allowed in
                if let viewControllers = self.viewControllers,
                    let recordController = viewControllers[0] as? TrackRecordViewController,
                    let tracksController = viewControllers[1] as? TrackListViewController {
                    if allowed {
                        recordController.isAudioRecordingGranted = true
                        tracksController.isAudioPlayingGranted = true
                    }
                }
            }
        } catch let error {
            showAlert(withMessage: error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isSplashWasShown {
            let splashController = storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
            present(splashController, animated: false, completion: nil)
            
            isSplashWasShown = true
        }
    }

}
