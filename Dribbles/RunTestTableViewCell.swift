//
//  RunTestTableViewCell.swift
//  Dribbles
//
//  Created by Alistair Logie on 1/8/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import Foundation
import UIKit

class RunTestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableTestWord: UILabel!
    @IBOutlet weak var tableTestScore: UILabel!
    
    @IBOutlet var phonemeButtons: [UIButton]!
    
    
    var phonemeButtonCount = 6
    
    enum PhonemeStatus {
        case correct, incorrect, blank
    }
    
    var phonemeStatuses: [PhonemeStatus] = [.blank, .blank, .blank, .blank, .blank, .blank]
    
    
    
    var maxScore = 0
    var score = 0 {
        didSet {
            tableTestScore.text = "\(score)/\(maxScore)"
        }

    }
    
    
    func configureCell(testElement: TestElement, rowNumber: Int) {
        
        tableTestWord.text = testElement.testWord
        maxScore = testElement.testPhonemes.count
        score = maxScore
        tableTestScore.text = "\(score)/\(maxScore)"
        
        if testElement.testPhonemes.count > 0 {
            var newStatus: PhonemeStatus
            for i in  0 ..< phonemeButtonCount - 1 {
                var phoneme = ""
 //               phonemeButton = UIButton()
                if i >= testElement.testPhonemes.count {
                    phoneme = ""
                } else {
                    phoneme = testElement.testPhonemes[i]
                }

                
                newStatus = configureButton(button: phonemeButtons[i], title: phoneme, phonemeStatus: phonemeStatuses[i])
                print(phonemeStatuses[i])
              

                print("Number of phonemes is \(testElement.testPhonemes.count)")

            
            }
            
        }
    }
    

    
    @IBAction func phonemeButtonTapped(_ sender: Any) {
        if self.backgroundView == .red {
            self.backgroundColor = UIColor(red: 0, green: 120, blue: 0, alpha: 0.2)
            score = score + 1
            //            phonemeStatus = true
        } else {
            self.backgroundColor = .red
            score = score - 1
            //            phonemeStatus = false
        }
    
        
    }
    
    
    func configureButton(button: UIButton, title: String, phonemeStatus: PhonemeStatus) -> PhonemeStatus {
        button.setTitle(title, for: .normal)
        var buttonStatus = phonemeStatus
        button.layer.cornerRadius = 10
        if title == "" {
            button.isUserInteractionEnabled = false
            button.backgroundColor = .white
            buttonStatus = .blank
        } else {
            button.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
            buttonStatus = .correct
            
        }
        return buttonStatus
    }
    
    
    
    
    
}
