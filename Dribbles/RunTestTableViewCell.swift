//
//  RunTestTableViewCell.swift
//  Dribbles
//
//  Created by Alistair Logie on 1/8/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import Foundation
import UIKit
//
protocol CellToTableDelegate: AnyObject {
    func buttonInCellTapped(cell: RunTestTableViewCell, tag: Int, row: Int)
}
//
class RunTestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableTestWord: UILabel!
    @IBOutlet weak var tableTestScore: UILabel!
    @IBOutlet var phonemeButtons: [UIButton]!
    
    weak var delegate: CellToTableDelegate?
    
    var phonemeButtonCount = 6
    let blankPhoneme = ""
    var buttonIndex = 0
    var cellRow = 0
    var maxScore = 0
    var score = 0 {
        didSet {
            tableTestScore.text = "\(score)/\(maxScore)"
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }

    func configureCell(tableCellData: TableCellData, rowNumber: Int) {

        cellRow = rowNumber
        tableTestWord.text = tableCellData.word
        maxScore = tableCellData.maxScore
        score = tableCellData.score
        tableTestScore.text = "\(score)/\(maxScore)"
        
        var phonemeTitles = tableCellData.testPhonemes
        while phonemeTitles.count < phonemeButtonCount {
            phonemeTitles.append(blankPhoneme)
        }
        // this is where the settings for all the buttons etc for each cell are already set
        for i in 0 ..< phonemeButtonCount {

            phonemeButtons[i].setTitle(phonemeTitles[i], for: .normal)
            phonemeButtons[i].layer.cornerRadius = 10
            phonemeButtons[i].tag = i
            phonemeButtons[i].backgroundColor = .white
            switch tableCellData.buttonStates[i] {
            case .blank:
                phonemeButtons[i].backgroundColor = .white
            case .incorrect:
                phonemeButtons[i].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
            case .correct:
                phonemeButtons[i].backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
            case .endOfTest:
                phonemeButtons[i].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            }
            
            switch tableCellData.enabledStatuses[i] {
            case .enabled:
                phonemeButtons[i].isUserInteractionEnabled = true
            case .disabled:
                phonemeButtons[i].isUserInteractionEnabled = false
            }

            if phonemeButtons.count == phonemeButtonCount {
            } else {
                self.addSubview(phonemeButtons[i])
            }
        }
    }
    
    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
        buttonIndex = (sender.tag)
        delegate?.buttonInCellTapped(cell: self, tag: buttonIndex, row: cellRow)
    }
}
