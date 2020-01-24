//
//  TrackListViewController.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 19.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import UIKit
import AVFoundation

class TrackListViewController: UIViewController {

    @IBOutlet weak var recordsTableView: UITableView!
    
    private var audioPlayer: AVAudioPlayer?
    var isAudioPlayingGranted = false
    private var selectedCellIndexPath: IndexPath?
    private var records : [Record]!
    private var meterTimer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        records = getRecords(withURLsArray: getRecordURLs())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        records = getRecords(withURLsArray: getRecordURLs())
        recordsTableView.reloadData()
        if records.count > 0 {
            recordsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeAudioPlayer()
    }
    
    
    @objc private func actionPlay(_ sender: UIButton) {
        if isAudioPlayingGranted {
            if sender.isSelected {
                audioPlayer?.pause()
                meterTimer?.invalidate()
            } else {
                if audioPlayer == nil {
                    let record = records[sender.tag]
                    
                    if record.duration == nil {
                        selectedCellIndexPath = nil
                        return
                    }
                    
                    let filePath = getDataDirectory().appendingPathComponent(record.name).appendingPathExtension("m4a")
                    setupAudioPlayer(forFile: filePath)
                }
                audioPlayer?.play()
                setupMeterTimer()
            }
            
            sender.isSelected = !sender.isSelected
        } else {
            showAlert(withMessage: "Don't have access to use microphone on your device.")
        }
    }
    
    @objc private func updateMeter() {
        let row = selectedCellIndexPath!.row
        let record = records[row]
        if let audioPlayer = audioPlayer,
            let duration = record.duration {
            let left = duration - audioPlayer.currentTime
            let cell = recordsTableView.cellForRow(at: IndexPath(row: row, section: 0)) as! TrackTableViewCell
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: Int(left))
            cell.trackDurationLabel.text = hoursMinutesSecondsToString(hours, minutes, seconds)
            
            cell.audioView.currentX = CGFloat(audioPlayer.currentTime) / CGFloat(duration) * (cell.audioView.frame.width - cell.audioView.circleRadius)
            cell.audioView.setNeedsDisplay()
        }
    }
    
    
    private func getRecordURLs() -> [URL] {
        var recordURLs = [URL]()
        
        let path = getDataDirectory()
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            
            for content in contents {
                if content.absoluteString.hasSuffix(".m4a") {
                    recordURLs.append(content)
                }
            }
        } catch let error {
            showAlert(withMessage: error.localizedDescription)
        }
        
        return recordURLs
    }
    
    private func getRecords(withURLsArray urls: [URL]) -> [Record] {
        var records = [Record]()
        
        for url in urls {
            let audioAsset = AVURLAsset.init(url: url, options: nil)
            let name = removeExtension(fromFileName: url.lastPathComponent)
            let date = audioAsset.creationDate?.value
            let durationSec = CMTimeGetSeconds(audioAsset.duration)
            let duration = durationSec == 0 ? nil : durationSec
            
            var record = Record(name: name, creationDate: nil, duration: duration)
            if let date = date as? Date {
                record.creationDate = date
            }
            
            records.append(record)
        }
        
        sortRecordsByDate(&records)
        return records
    }
    
    private func sortRecordsByDate(_ records: inout [Record]) {
        records.sort { (rec1, rec2) -> Bool in
            if let date1 = rec1.creationDate,
                let date2 = rec2.creationDate {
                if date1 == date2 {
                    return rec1.name < rec2.name
                }
                return date1 > date2
            }
            return rec1.name < rec2.name
        }
    }
    
    private func dateToString(_ date : Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                dateFormatter.dateFormat = "hh:mm"
            } else {
                dateFormatter.dateFormat = "dd MMM yyyy"
            }
            
            return dateFormatter.string(from: date)
        } else {
            return "-"
        }
    }
    
    private func removeExtension(fromFileName fileName : String) -> String {
        var components = fileName.components(separatedBy: ".")
        if components.count > 1 {
            components.removeLast()
            return components.joined(separator: ".")
        } else {
            return fileName
        }
    }
    
    private func setupAudioPlayer(forFile filePath: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch let error {
            showAlert(withMessage: error.localizedDescription)
        }
    }
    
    private func setupMeterTimer() {
        meterTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    private func removeAudioPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
        meterTimer?.invalidate()
        
        if selectedCellIndexPath != nil {
            let record = records[selectedCellIndexPath!.row]
            let lastCell = recordsTableView.cellForRow(at: selectedCellIndexPath!) as! TrackTableViewCell
            lastCell.audioView.currentX = 0
            lastCell.audioView.setNeedsDisplay()
            lastCell.playButton.isSelected = false
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: Int(record.duration!))
            lastCell.trackDurationLabel.text = hoursMinutesSecondsToString(hours, minutes, seconds)
            selectedCellIndexPath = nil
            recordsTableView.beginUpdates()
            recordsTableView.endUpdates()
        }
    }
}


// MARK: - UITableViewDataSourse, UITableViewDelegate -
extension TrackListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as! TrackTableViewCell
        
        let record = records[indexPath.row]
        cell.trackNameLabel.text = record.name
        cell.trackCreationDateLabel.text = dateToString(record.creationDate)
        if let duration = record.duration {
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: Int(duration))
            cell.trackDurationLabel.text = hoursMinutesSecondsToString(hours, minutes, seconds)
        } else {
            cell.trackDurationLabel.text = "--:--:--"
        }
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(actionPlay), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removeAudioPlayer()
        
        selectedCellIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let record = records[indexPath.row]
            let filePath = getDataDirectory().appendingPathComponent(record.name).appendingPathExtension("m4a")
            do {
                try FileManager.default.removeItem(at: filePath)
            }
            catch let error {
                showAlert(withMessage: error.localizedDescription)
                return
            }
            
            tableView.beginUpdates()
            records.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedCellIndexPath {
            return 170
        }
        
        return 90
    }
    
}


// MARK: - AVAudioPlayerDelegate -
extension TrackListViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let cell = recordsTableView.cellForRow(at: selectedCellIndexPath!) as! TrackTableViewCell
        
        cell.audioView.currentX = 0
        cell.audioView.setNeedsDisplay()
        
        let record = records[selectedCellIndexPath!.row]
        let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: Int(record.duration!))
        cell.trackDurationLabel.text = hoursMinutesSecondsToString(hours, minutes, seconds)
        
        cell.playButton.isSelected = false
        meterTimer?.invalidate()
    }
}
