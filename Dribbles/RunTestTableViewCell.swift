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
    @IBOutlet var collectionOfButtons: Array<UIButton>!
    
    var phonemeButtons: [UIButton]?
    var phonemeButton: UIButton?
    var maxNumberOfButtons = 6
    
    func configureCell(testElement: TestElement, rowNumber: Int) {
        collectionOfButtons.removeAll(keepingCapacity: true)
        tableTestWord.text = testElement.testWord
        
        if testElement.testPhonemes.count > 0 {
            
            for i in  0 ..< testElement.testPhonemes.count {
                
 //               phonemeButton = UIButton()
                let phoneme = testElement.testPhonemes[i]
                
                //let newButton = UIButton(type: )
                collectionOfButtons.append(UIButton())
                if phoneme != "" {
                    collectionOfButtons[i].setTitle(phoneme, for: .normal)
                }
//                collectionOfButtons[i].setTitle(phoneme, for: .normal)
                collectionOfButtons[i].tag = (rowNumber * 1000) + i
                collectionOfButtons[i].backgroundColor = UIColor.lightGray
//                collectionOfButtons[i].addTarget(self, action: #selector(phonemeButtonTapped(btn:)), for: .touchUpInside)
                print("Number of phonemes is \(testElement.testPhonemes.count)")
                print("Number of buttons is \(collectionOfButtons.count)")
//                print("got in here")
                
                print("Phoneme number \(i) is \(phoneme)")
                print("Button title is \(collectionOfButtons![i].currentTitle ?? "Didn't work")")
                self.contentView.addSubview(collectionOfButtons[i])
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
    
    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
        print("Phoneme button tapped")
        switch sender.backgroundColor {
        case UIColor.lightGray:
            sender.backgroundColor = UIColor.green
        case UIColor.green:
            sender.backgroundColor = UIColor.red
        case UIColor.red:
            sender.backgroundColor = UIColor.lightGray
        case UIColor.green:
            sender.backgroundColor = UIColor.green
        case UIColor.orange:
            sender.backgroundColor = UIColor.lightGray
        default:
            sender.backgroundColor = UIColor.orange
        }
        
        print(sender.tag)
        
    }
}
