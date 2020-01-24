//
//  Utils.swift
//  DSPLabsTestProject
//
//  Created by Анастасия Распутняк on 21.01.2020.
//  Copyright © 2020 Anastasiya Rasputnyak. All rights reserved.
//

import Foundation
import UIKit

func getDataDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    let dataDirectory = documentsDirectory.appendingPathComponent("Records")
    return dataDirectory
}

func secondsToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

func timeParamToString(param : Int) -> String {
    return param / 10 > 0 ? String(param) : "0\(param)"
}

func hoursMinutesSecondsToString(_ h: Int, _ m: Int, _ s: Int) -> String {
    let hours = timeParamToString(param: h)
    let minutes = timeParamToString(param: m)
    let seconds = timeParamToString(param: s)
    return "\(hours):\(minutes):\(seconds)"
}

extension UIViewController {
    func showAlert(withMessage msg: String) {
        let alert = UIAlertController(title: "Error ocured", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
