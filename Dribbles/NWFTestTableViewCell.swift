//
//  NWFTestTableViewCell.swift
//  Dribbles
//
//  Created by Alistair Logie on 4/14/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import Foundation
import UIKit

protocol NWFCellToTableDelegate: class {
    func buttonInCellTapped(cell: NFWTestTableViewCell, tag: Int, row: Int)
}

class NFWTestTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var tableTestScore: UILabel!
    @IBOutlet var phonemeButtons: [UIButton]!
    
    weak var delegate: NWFCellToTableDelegate?
    
    var tableTestWord: UILabel = UILabel()
    var phonemeButtonCount = 15
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
        
        print("phoneme buttons count \(phonemeButtons.count)")
        cellRow = rowNumber
        tableTestWord.text = tableCellData.word
        maxScore = tableCellData.maxScore
        score = tableCellData.score
        tableTestScore.text = "\(score)/\(maxScore)"
        
        var phonemeTitles = tableCellData.testPhonemes
//        while phonemeTitles.count < phonemeButtonCount {
//            phonemeTitles.append(blankPhoneme)
//        }
        
        for i in 0 ..< phonemeButtonCount {
            
            phonemeButtons[i].setTitle(phonemeTitles[i], for: .normal)
            phonemeButtons[i].layer.cornerRadius = 10
            phonemeButtons[i].tag = i
//            print("Button tag is \(phonemeButtons[i].tag)")
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
//                print("phoneme buttons count \(phonemeButtons.count)")
            }
        }
    }
    
    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
        buttonIndex = (sender.tag)
        print("In cell a button was tapped at tag \(buttonIndex) and row \(cellRow)")
        delegate?.buttonInCellTapped(cell: self, tag: buttonIndex, row: cellRow)
    
    }
    
}
