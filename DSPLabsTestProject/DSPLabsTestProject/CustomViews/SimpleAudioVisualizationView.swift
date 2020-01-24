//
//  SimpleAudioVisualizationView.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 23.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit

class SimpleAudioVisualizationView: UIView {
    
    private let centerLine = UIView()
    var currentX: CGFloat = 0
    let circleRadius: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    
    override func draw(_ rect: CGRect) {
        setupCenterLine()
        
        let rect = CGRect(x: currentX, y: frame.height / 2 - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
        let circle = UIBezierPath(ovalIn: rect)
        
        UIColor.white.set()
        circle.fill()
    }
    
    private func setupCenterLine() {
        centerLine.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        centerLine.alpha = 0.5
        
        centerLine.frame = CGRect(x: 0, y: frame.height / 2 - 1, width: frame.width, height: 2)
        addSubview(centerLine)
    }


}
