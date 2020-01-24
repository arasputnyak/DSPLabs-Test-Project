//
//  SplashViewController.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 23.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appNoteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.animate(withDuration: 2.5,
                       animations: {
                        let oldFrame = self.appNameLabel.frame
                        self.appNameLabel.frame = CGRect(x: oldFrame.origin.x - oldFrame.width - 15,
                                                         y: oldFrame.origin.y,
                                                         width: oldFrame.width,
                                                         height: oldFrame.height)
                        self.appNameLabel.alpha = 0
                        
                        let oldFrame2 = self.appNoteLabel.frame
                        self.appNoteLabel.frame = CGRect(x: oldFrame2.origin.x + self.view.frame.width,
                                                         y: oldFrame2.origin.y,
                                                         width: oldFrame2.width,
                                                         height: oldFrame2.height)
                        self.appNoteLabel.alpha = 0
        },
                       completion: { (finished) in
                        if finished {
                            self.presentingViewController?.dismiss(animated: false, completion: nil)
                        }
        })
    }

}
