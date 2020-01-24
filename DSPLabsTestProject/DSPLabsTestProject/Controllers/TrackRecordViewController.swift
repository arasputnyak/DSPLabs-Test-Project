//
//  TrackRecordViewController.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 17.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit
import AVFoundation

class TrackRecordViewController: UIViewController {

    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var audioView: AudioVisualizationView!
    
    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private var powerTimer: Timer?
    var isAudioRecordingGranted = false
    private var currentTime = 0 {
        didSet {
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: currentTime)
            trackDurationLabel.text = hoursMinutesSecondsToString(hours, minutes, seconds)
        }
    }
    private var powerData = [CGFloat]()
    private var numberOfRecords = 0
    private let prefix = "New Recording"

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let number = UserDefaults.standard.object(forKey: "numberOfRecords") as? Int {
            numberOfRecords = number
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeAudioRecorder()
    }

    
    @IBAction func actionRecord(_ sender: UIButton) {
        if isAudioRecordingGranted {
            if sender.isSelected {
                audioRecorder?.pause()
                meterTimer?.invalidate()
                powerTimer?.invalidate()
            } else {
                if audioRecorder == nil {
                    setupAudioRecorder()
                }
                audioRecorder?.record()
                setupMeterTimer()
                setupPowerTimer()
            }
            
            sender.isSelected = !sender.isSelected
        } else {
            showAlert(withMessage: "Don't have access to use microphone on your device.")
        }
        
    }
    
    @IBAction func actionStop(_ sender: UIButton) {
        removeAudioRecorder()
    }
    
    
    @objc private func updateMeter() {
        if let audioRecorder = audioRecorder {
            currentTime = Int(audioRecorder.currentTime)
        }
    }
    
    @objc private func updatePower() {
        if let audioRecorder = audioRecorder {
            if powerData.count >= audioView.barNumber {
                powerData.remove(at: 0)
            }
            powerData.append((160 + CGFloat(audioRecorder.averagePower(forChannel: 0))) * 0.2)
            // print((160 + CGFloat(audioRecorder.averagePower(forChannel: 0))) * 0.2)
            audioRecorder.updateMeters()
            
            audioView.data = powerData
            audioView.setNeedsDisplay()
        }
    }
    
    
    private func setupAudioRecorder() {
        do {
            numberOfRecords += 1
            let filePath = getDataDirectory().appendingPathComponent("\(prefix) \(numberOfRecords).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            
        } catch let error {
            numberOfRecords -= 1
            showAlert(withMessage: error.localizedDescription)
        }
    }
    
    private func setupMeterTimer(){
        meterTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    private func setupPowerTimer() {
        powerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePower), userInfo: nil, repeats: true)
    }
    
    private func removeAudioRecorder() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        meterTimer?.invalidate()
        powerTimer?.invalidate()
        currentTime = 0
        powerData = []
        audioView.data = []
        audioView.setNeedsDisplay()
        recordButton.isSelected = false
        UserDefaults.standard.set(numberOfRecords, forKey: "numberOfRecords")
    }
    
}
