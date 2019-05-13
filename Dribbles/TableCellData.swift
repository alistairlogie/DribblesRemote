//
//  TableCellData.swift
//  Dribbles
//
//  Created by Alistair Logie on 4/8/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import UIKit

class TableCellData {
// This defines the contents of the table cell
    enum ButtonStatus {
        case correct, incorrect, blank, endOfTest
    }
    enum ButtonEnabled {
        case enabled, disabled
    }
    var word = ""
    var enabledStatuses: [ButtonEnabled] = []
    var buttonStates: [ButtonStatus] = []
    var testPhonemes: [String] = []
    var score: Int = 0
    var maxScore: Int = 0
    
}
