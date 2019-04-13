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
protocol CellToTableDelegate: class {
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
//
//
    func configureCell(tableCellData: TableCellData, rowNumber: Int) {
//
        cellRow = rowNumber
        tableTestWord.text = tableCellData.word
        maxScore = tableCellData.maxScore
        score = tableCellData.score
        tableTestScore.text = "\(score)/\(maxScore)"
        
        var phonemeTitles = tableCellData.testPhonemes
        while phonemeTitles.count < phonemeButtonCount {
            phonemeTitles.append(blankPhoneme)
        }
        
        for i in 0 ..< phonemeButtonCount {
            
            let newButton = configureButton(title: phonemeTitles[i], status: tableCellData.buttonStates[i], index: i)

            if phonemeButtons.count == phonemeButtonCount {
                
            } else {
                print("newButton title is \(newButton.titleLabel!)")
                phonemeButtons.append(newButton)
            }

            print("After appending a button, i is \(i) and count is \(phonemeButtons.count)")
        }
    }

    func configureButton(title: String, status: TableCellData.ButtonStatus, index: Int)-> UIButton {

        let button = UIButton()
        button.setTitle(title, for: .normal)
        
        button.layer.cornerRadius = 10
        button.tag = index
        switch status {
        case .blank:
            button.isUserInteractionEnabled = false
            button.backgroundColor = .lightGray
        case .incorrect:
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
        case .correct:
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
        }
        print("button title is \(button.titleLabel!)")
        return button
    }
    
    
    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
        buttonIndex = (sender.tag)
        delegate?.buttonInCellTapped(cell: self, tag: buttonIndex, row: cellRow)
        print("button tapped")
    }
}
