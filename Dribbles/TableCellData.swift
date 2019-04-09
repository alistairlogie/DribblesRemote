//
//  TableCellData.swift
//  Dribbles
//
//  Created by Alistair Logie on 4/8/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import UIKit

class TableCellData {
    
    enum ButtonStatus {
        case correct, incorrect, blank
    }
    var word = ""
    var buttonStates: [ButtonStatus] = []
    var testPhonemes: [String] = []
    var score: Int = 0
}
