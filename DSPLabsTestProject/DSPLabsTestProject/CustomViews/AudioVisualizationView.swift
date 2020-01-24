//
//  AudioVisualizationView.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 22.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit

class AudioVisualizationView: UIView {
    
    private let centerLine = UIView()
    private var barColor: UIColor!
    private var barWidth: CGFloat = 3
    private var barInterval: CGFloat = 2
    private let dMax: CGFloat = 160
    lazy var barNumber = Int((frame.width - 40) / (barWidth + barInterval))
    
    private let minVal: CGFloat = 22
    private lazy var maxVal: CGFloat = frame.height / 2
    private let realMaxVal: CGFloat = 26
    
    private var currentX: CGFloat = 0
    var data = [CGFloat]()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        prepareData()
        currentX = 0
        
        for (i, d) in data.enumerated() {
            let bPath = UIBezierPath()
            bPath.lineWidth = barWidth
            
            if currentX < frame.width - 20 {
                currentX += barInterval + barWidth
            }
            let y1 = (frame.height - d) / 2
            bPath.move(to: CGPoint(x:currentX, y: y1))
            
            let y2 = y1 + d
            bPath.addLine(to: CGPoint(x: currentX, y: y2))
            
            barColor = i % 2 == 1 ? #colorLiteral(red: 0.6884204149, green: 0.5629273653, blue: 0.9584950805, alpha: 1) : #colorLiteral(red: 0.3816333413, green: 0.253233403, blue: 0.7791885734, alpha: 1)
            barColor.set()
            bPath.stroke()
        }
        
        setupCenterLine()
    }
    
    private func setupCenterLine() {
        centerLine.backgroundColor = #colorLiteral(red: 0.8731690049, green: 0.3664031029, blue: 0.520632565, alpha: 1)
        let height: CGFloat = 4
        centerLine.layer.shadowOffset = .zero
        centerLine.layer.shadowRadius = 15
        centerLine.layer.shadowOpacity = 0.9
        centerLine.layer.shadowColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        centerLine.frame = CGRect(x: 0, y: (frame.height - height) / 2, width: frame.width, height: height)
        addSubview(centerLine)
    }
    
    private func prepareData() {
//        data = data.map({ (d) -> CGFloat in
//            let tempVal = ((dMax - d) / dMax * (frame.height - 13)) + 3
//            return tempVal > 100 ? tempVal + 30 : tempVal - 30
//        })
        
        // data = data.map({ (dMax - $0) / dMax * (frame.height / 2 - 5) + 5 })
        let q: CGFloat = pow(maxVal / minVal, 1 / (realMaxVal - minVal - 1))
        
        data = data.map({
            if $0 <= minVal {
                return minVal
            }
            if $0 >= realMaxVal {
                return maxVal
            }
            
            return minVal * pow(q, $0 - minVal)
        })
    }

}
