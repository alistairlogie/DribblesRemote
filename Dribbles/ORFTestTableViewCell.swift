//
//  ORFTestTableViewCell.swift
//  Dribbles
//
//  Created by Alistair Logie on 7/26/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import Foundation
import UIKit
//
protocol ORFCellToTableDelegate: AnyObject {
    func buttonInCellTapped(cell: ORFTestTableViewCell, tag: Int, row: Int)
}

class ORFTestTableViewCell: UITableViewCell {

    @IBOutlet weak var tableTestScore: UILabel!
    @IBOutlet var wordButtons: [UIButton]!
    
    weak var delegate: ORFCellToTableDelegate?
    
    var tableTestWord: UILabel = UILabel()
    var wordButtonCount = 18
    let blankWord = ""
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
    
    func configureCell(tableCellData: ORFTableCellData, rowNumber: Int) {
    
        cellRow = rowNumber
        tableTestWord.text = tableCellData.word
        maxScore = tableCellData.maxScore
        score = tableCellData.score
        tableTestScore.text = "\(score)/\(maxScore)"
        
        var wordTitles = tableCellData.testWords
        while wordTitles.count < wordButtonCount {
            wordTitles.append(blankWord)
        }
        
        for i in 0 ..< wordButtonCount {
            
            wordButtons[i].setTitle(wordTitles[i], for: .normal)
            wordButtons[i].layer.cornerRadius = 5
            wordButtons[i].tag = i
            wordButtons[i].backgroundColor = .white
            switch tableCellData.buttonStates[i] {
            case .blank:
                wordButtons[i].backgroundColor = .white
            case .incorrect:
                wordButtons[i].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
            case .correct:
                wordButtons[i].backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
            case .endOfTest:
                wordButtons[i].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            }
            
            switch tableCellData.enabledStatuses[i] {
            case .enabled:
                wordButtons[i].isUserInteractionEnabled = true
            case .disabled:
                wordButtons[i].isUserInteractionEnabled = false
            }
            
            if wordButtons.count == wordButtonCount {
                print(wordButtons.count)
            } else {
//                print("Adding a button")
                self.addSubview(wordButtons[i])
            }
        }
    }
    
    @IBAction func wordButtonPressed(_ sender: UIButton) {
        buttonIndex = (sender.tag)
        delegate?.buttonInCellTapped(cell: self, tag: buttonIndex, row: cellRow)
    }
}
