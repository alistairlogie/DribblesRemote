//
//  RunTestTableViewCell.swift
//  Dribbles
//
//  Created by Alistair Logie on 1/8/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import Foundation
import UIKit

protocol RunTestTableViewCellDelegate: class {
    func buttonTapped(cell: RunTestTableViewCell, buttonIndex: Int, button: UIButton)
}

class RunTestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableTestWord: UILabel!
    @IBOutlet weak var tableTestScore: UILabel!
    @IBOutlet var phonemeButtons: [UIButton]!
    
    weak var delegate: RunTestTableViewCellDelegate?
    
    var phonemeButtonCount = 6
    
    enum PhonemeStatus {
        case correct, incorrect, blank
    }

    
    var masterRowNumber = Int()
    var phonemeStatuses = [PhonemeStatus]() // = [.blank, .blank, .blank, .blank, .blank, .blank]
    var selectedButton = UIButton()
    var masterButtonIndex = 0
    var cellDataStore = [[PhonemeStatus]]()
 
    var maxScore = 0
    var score = 0 {
        didSet {
            tableTestScore.text = "\(score)/\(maxScore)"
        }
    
    }
    
    
    func configureCell(testElement: TestElement, rowNumber: Int) {
        
//        cellDataStore[99] = [.blank, .blank, .blank, .blank, .blank, .blank]
//        cellDataStore[98] = [.blank, .blank, .blank, .blank, .blank, .blank]

//        masterRowNumber = rowNumber
        if cellDataStore.indices.contains(rowNumber) {
            print("Row \(Int(rowNumber)) already exists!")
        } else {
            print("Creating data for row \(rowNumber)")
        }

        
        tableTestWord.text = testElement.testWord
        maxScore = testElement.testPhonemes.count
        score = maxScore
        tableTestScore.text = "\(score)/\(maxScore)"
        

        if testElement.testPhonemes.count > 0 {
            for i in  0 ..< phonemeButtonCount {
             
                    var phoneme = ""
                    //               phonemeButton = UIButton()
                    if i >= testElement.testPhonemes.count {
                        phoneme = ""
                        if cellDataStore.indices.contains(rowNumber) && phonemeStatuses.count == 6 {
//                            print("Here's what I found for row \(rowNumber) \(cellDataStore[rowNumber])")
                            phonemeStatuses = cellDataStore[rowNumber]
                        } else {
                            if phonemeStatuses.indices.contains(i) {
//                                phonemeStatuses[i] = .blank
                            } else {
                                phonemeStatuses.append(.blank)
                            }
                        }
                        
                        //                    phonemeStatuses[i] = .blank
                    } else {
                        phoneme = testElement.testPhonemes[i]
                        if cellDataStore.indices.contains(rowNumber) && phonemeStatuses.count == 6 {
//                        print("Here's what I found for row \(rowNumber)")
                            phonemeStatuses = cellDataStore[rowNumber]
                            
                        } else {
                            
                            if phonemeStatuses.indices.contains(i) {
//                                phonemeStatuses[i] = .correct
                            } else {
                                phonemeStatuses.append(.correct)
                            }
                        }
                        
                    }
 //               cellDataStore[rowNumber] = phonemeStatuses
                configureButton(button: phonemeButtons[i], title: phoneme, status: phonemeStatuses[i], row: rowNumber, index: i)
            }
            if !cellDataStore.indices.contains(rowNumber) {
                cellDataStore.append(phonemeStatuses)
                print("CC1: Adding \(rowNumber) as a new row)")
            } else {
                print("These are the current phonemes \(phonemeStatuses)")
                cellDataStore[rowNumber] = phonemeStatuses
                print("CC1: Updating \(rowNumber))")

            }
            print("first write of row \(rowNumber)")

        }
//        cellStatus.append(phonemeStatuses)
//        cellDataStore = [rowNumber:phonemeStatuses]
//        print("Trying to add key \(Int(rowNumber)) and value \(phonemeStatuses)")
//        if !cellDataStore.indices.contains(rowNumber) {
//            cellDataStore.append(phonemeStatuses)
//            print("CC2: Adding \(rowNumber) as a new row)")
//        } else {
//            cellDataStore[rowNumber] = phonemeStatuses
//            print("CC2: Updating \(rowNumber)")
//
//        }
//        print("second write of row \(rowNumber)")
//        print("The current data for row \(rowNumber) is \(cellDataStore[rowNumber])")
//        print("Dictionary is \(cellDataStore)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }

    
    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
        let buttonIndex = (sender.tag - 100)
        masterButtonIndex = buttonIndex
        selectedButton = sender
        self.delegate?.buttonTapped(cell: self, buttonIndex: masterButtonIndex, button: selectedButton)
        
    }
    
    func updateButton(row: Int, buttonIndex: Int, button: UIButton) {
//        buttonIndex = (sender.tag - 100)
        //        var buttonIndex = 0
//        buttonIndex = (sender.tag - 100)
//        print("Update button statuses \(phonemeStatuses)")
        if phonemeStatuses[buttonIndex] == .incorrect {
            phonemeStatuses[buttonIndex] = .correct
            button.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
            score = score + 1
        } else {
            phonemeStatuses[buttonIndex] = .incorrect
            button.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.2)
            score = score - 1
        }
        if !cellDataStore.indices.contains(row) {
            cellDataStore.append(phonemeStatuses)
            print("UD: Adding \(row) as a new row)")
        } else {
            
            print("2nd display of phonemes \(phonemeStatuses)")
            cellDataStore[row] = phonemeStatuses
            print("UD: Updating \(row)")
        }
//        print("third write of row \(row)")
//        print("Here is the updated row information for row \(row) \(cellDataStore[row])")
    }
    
    func configureButton(button: UIButton, title: String, status: PhonemeStatus, row: Int, index: Int) {
//        print("I think I'm on row \(row)")
        button.setTitle(title, for: .normal)
//        var buttonStatus = phonemeStatus
        button.layer.cornerRadius = 10
        if title == "" {
            button.isUserInteractionEnabled = false
            button.backgroundColor = .white
            phonemeStatuses[index] = .blank
        } else {
            if status == .incorrect {
                button.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.2)
                score = score - 1
            } else {
                button.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
                phonemeStatuses[index] = .correct
            }
        }
        if !cellDataStore.indices.contains(row) {
            cellDataStore.append(phonemeStatuses)
            print("CB: Adding \(row) as a new row)")
        } else {
            cellDataStore[row] = phonemeStatuses
            print("CB: Updating \(row)")
        }
//        print("Writing from  \(row)")
//       print("Current Dictionary row \(row) \(cellDataStore[row])")
//        print("There are \(cellDataStore.count) records in the dictionary")
        
        
    }
  
}
