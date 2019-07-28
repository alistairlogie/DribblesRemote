//
//  ORFTableCellData.swift
//  Dribbles
//
//  Created by Alistair Logie on 7/26/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import UIKit

class ORFTableCellData {
// This defines the contents of the table cell for the ORF
    enum ButtonStatus {
        case correct, incorrect, blank, endOfTest
    }
    enum ButtonEnabled {
        case enabled, disabled
    }
    
    var enabledStatuses: [ButtonEnabled] = []
    var buttonStates: [ButtonStatus] = []
    var testWords: [String] = []
    var score: Int = 0
    var maxScore: Int = 0
}
