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
//                print("Phoneme is \(phoneme)")
//                phonemeButtons[i].setTitle(phoneme, for: .normal)
                //let newButton = UIButton(type: )
                
                newStatus = configureButton(button: phonemeButtons[i], title: phoneme, phonemeStatus: phonemeStatuses[i])
                print(phonemeStatuses[i])
              
//                switch i {
//                case 0:
////                    phoneme1.setTitle(phoneme, for: .normal)
////                    phoneme1.backgroundColor = .green
////                    if phoneme == "" {
////                        phoneme1.isUserInteractionEnabled = false
////                    }
//                    configureButton(button: phoneme1, title: phoneme)
//                case 1:
////                    phoneme2.setTitle(phoneme, for: .normal)
////                    if phoneme == "" {
////                        phoneme2.isUserInteractionEnabled = false
////                    }
//                    configureButton(button: phoneme2, title: phoneme)
//                case 2:
////                    phoneme3.setTitle(phoneme, for: .normal)
////                    if phoneme == "" {
////                        phoneme3.isUserInteractionEnabled = false
////                    }
//                    configureButton(button: phoneme3, title: phoneme)
//                case 3:
////                    phoneme4.setTitle(phoneme, for: .normal)
////                    if phoneme == "" {
////                        phoneme4.isUserInteractionEnabled = false
////                    }
//                    configureButton(button: phoneme4, title: phoneme)
//                case 4:
////                    phoneme5.setTitle(phoneme, for: .normal)
////                    if phoneme == "" {
////                        phoneme5.isUserInteractionEnabled = false
////                    }
//                    configureButton(button: phoneme5, title: phoneme)
//                case 5:
////                    phoneme6.setTitle(phoneme, for: .normal)
////                    if phoneme == "" {
////                        phoneme6.isUserInteractionEnabled = false
////                    }
//                    configureButton(button: phoneme6, title: phoneme)
//                default:
//                    return
//                }
//
                
//                collectionOfButtons[i].setTitle(phoneme, for: .normal)
               
//                collectionOfButtons[i].backgroundColor = UIColor.lightGray
//                collectionOfButtons[i].addTarget(self, action: #selector(phonemeButtonTapped(btn:)), for: .touchUpInside)
                print("Number of phonemes is \(testElement.testPhonemes.count)")
//                print("Number of buttons is \(collectionOfButtons.count)")
//                print("got in here")
                
//                print("Phoneme number \(i) is \(phoneme)")
//                print("Button title is \(collectionOfButtons![i].currentTitle ?? "Didn't work")")
//                self.contentView.addSubview(collectionOfButtons[i])
//                self.addSubview(collectionOfButtons[i])
                
//                collectionOfButtons.append(phonemeButton)
//                collectionOfButtons[i].setTitle(phoneme, for: .normal)
                
        //        let rowNum = (indexPath.row + 1) * 1000
        //        let tag = rowNum + i + 1
        //        currentButton.tag = tag
                //                currentButton.addTarget(self, action: #selector(phonemeButtonSelected(_:)), for: .touchUpInside)
                
//                if collectionOfButtons?.append(currentButton as! UIButton) {
//
//                }
//                
                
            }
            
//            for subview in self.subviews where subview.tag == 1001 {
//                print("Found some buttons")
//                let btn = subview as! UIButton
//                phonemeButtons?.append(btn)
//                btn.addTarget(self, action: #selector(phonemeButtonTapped), for: .touchUpInside)
//
//            }
//            addSubview(collectionOfButtons) as! [UIButton]
//            tableTestScore.text = ("\(testElement.testPhonemes.count)/\(testElement.testPhonemes.count)")
//           for i in 0 ..< collectionOfButtons.count {
//                self.addSubview(collectionOfButtons[i])
//            }
            
        }
            
    }
    
//    @objc func phonemeButtonTapped(btn: UIButton) {
//        print("Button tapped")
//
//    }
    
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
