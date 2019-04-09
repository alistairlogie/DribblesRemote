//
//  RunTestTableViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/23/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

protocol CellToControllerDelegate: class {
    
}


class RunTestTableViewController: UIViewController {
    
    
    
    enum PhonemeStatus {
        case correct, incorrect, blank
    }

    
    var selectedTest = String()
    var currentStudent = String()
    var container: NSPersistentContainer!
    var todaysDate = Date()
    var updatedResults = [TestEvent]()
    var testLines = [String]()
    var testLine = String()
    var testElement = TestElement()
    var testElements = [TestElement]()
    var selectedButtonRow = 0
    
    var phonemeButtonCount = 6
    
    
    
    
    var masterRowNumber = Int()
    var phonemeStatuses = [PhonemeStatus]() // = [.blank, .blank, .blank, .blank, .blank, .blank]
    var selectedButton = UIButton()
    var masterButtonIndex = 0
    var cellDataStore = [[PhonemeStatus]]()
    var tableCellStore = [TableCellData]()
    
    var maxScore = 0
    var score = 0 {
        didSet {
            tableTestScore.text = "\(score)/\(maxScore)"
        }
        
    }
//    var cells = [RunTestTableViewCell]()
    
    
    
//    var phonemeButtons = [UIButton]()
//    var buttons = [UIButton]()
//    var currentButton = UIButton()
//    var currentButtons = [UIButton]()
    //var tappedPhonemeButtons = [UIButton]()
    
    
    @IBOutlet weak var runTestTable: UITableView!
 
    @IBOutlet weak var totalTestScore: UITextField!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.runTestTable.rowHeight = 61
        self.title = selectedTest
        print(currentStudent)
        print(selectedTest)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
        if let testFileListPath = Bundle.main.path(forResource: selectedTest, ofType: "txt") {
            if let testFileData = try? String(contentsOfFile: testFileListPath) {
                testLines = testFileData.components(separatedBy: "\n")
                //                    print("\(testLines.count) found.")
                for (_, testLine) in testLines.enumerated() {
                    if let newElement = decomposeTestLines(wholeTestLine: testLine) {
                       testElements.append(newElement)
                    }
                }
            }
        } else {
            testLines = ["no tests found"]
        }
        runTestTable.reloadData()
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    @objc func submitTestResultPressed(_ sender: UIBarButtonItem) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let todaysDate = Date()
        let testScore = totalTestScore.text
        let testScoreFloat = NSString(string: testScore!).floatValue
        let testEvent = TestEvent(context: PersistenceService.context)
        testEvent.testType = selectedTest
        testEvent.student = currentStudent
        testEvent.date = todaysDate as NSDate
        testEvent.score = testScoreFloat

        PersistenceService.saveContext()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func decomposeTestLines(wholeTestLine: String) -> TestElement? {
        let testChunks = wholeTestLine.components(separatedBy: ",")
        testElement.testWord = ""
        testElement.testPhonemes.removeAll()
        
        //print("Number of chunks is \(testChunks.count)")
        // make sure it's not a blank line
        if testChunks.count > 1 {
            //            print("\(testChunks.count) is apparently greater than 1")
            for (index, chunk) in testChunks.enumerated() {
                if chunk != "" {
                    //if it's the first chunk, set that as the test word
                    if index == 0 {
                        testElement.testWord = chunk
                        // if it's the second chunk or higher, add it to the phonemes array
                    } else {
                        testElement.testPhonemes.append(chunk)
                    }
                }
            }
            return testElement
        } else {
            return nil
        }
    }
 
//    func updateButton(row: Int, buttonIndex: Int, button: UIButton) {
//        //        buttonIndex = (sender.tag - 100)
//        //        var buttonIndex = 0
//        //        buttonIndex = (sender.tag - 100)
//        //        print("Update button statuses \(phonemeStatuses)")
//        if phonemeStatuses[buttonIndex] == .incorrect {
//            phonemeStatuses[buttonIndex] = .correct
//            button.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
//            score = score + 1
//        } else {
//            phonemeStatuses[buttonIndex] = .incorrect
//            button.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.2)
//            score = score - 1
//        }
//        if !cellDataStore.indices.contains(row) {
//            cellDataStore.append(phonemeStatuses)
//            print("UD: Adding \(row) as a new row)")
//        } else {
//
//            print("2nd display of phonemes \(phonemeStatuses)")
//            cellDataStore[row] = phonemeStatuses
//            print("UD: Updating \(row)")
//        }
//        //        print("third write of row \(row)")
//        //        print("Here is the updated row information for row \(row) \(cellDataStore[row])")
//    }
////    func buttonTapped(cell: RunTestTableViewCell, buttonIndex: Int, button: UIButton) {
//        if let indexPath = runTestTable.indexPath(for: cell) {
//            selectedButtonRow = indexPath.row
//
//            cell.updateButton(row: selectedButtonRow, buttonIndex: buttonIndex, button: button)
//        }
//    }
    
    
    
//    func configureButton(button: UIButton, title: String, status: PhonemeStatus, row: Int, index: Int) {
//        //        print("I think I'm on row \(row)")
//        button.setTitle(title, for: .normal)
//        //        var buttonStatus = phonemeStatus
//        button.layer.cornerRadius = 10
//        if title == "" {
//            button.isUserInteractionEnabled = false
//            button.backgroundColor = .white
//            phonemeStatuses[index] = .blank
//        } else {
//            if status == .incorrect {
//                button.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.2)
//                score = score - 1
//            } else {
//                button.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.2)
//                phonemeStatuses[index] = .correct
//            }
//        }
//        if !cellDataStore.indices.contains(row) {
//            cellDataStore.append(phonemeStatuses)
//            print("CB: Adding \(row) as a new row)")
//        } else {
//            cellDataStore[row] = phonemeStatuses
//            print("CB: Updating \(row)")
//        }
//        //        print("Writing from  \(row)")
//        //       print("Current Dictionary row \(row) \(cellDataStore[row])")
//        //        print("There are \(cellDataStore.count) records in the dictionary")
//        
//        
//    }
//    
//    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
//        let buttonIndex = (sender.tag - 100)
//        masterButtonIndex = buttonIndex
//        selectedButton = sender
////        self.delegate?.buttonTapped(cell: self, buttonIndex: masterButtonIndex, button: selectedButton)
//        updateButton(row: selectedButtonRow, buttonIndex: buttonIndex, button: sender)
//    }
//    
}



extension RunTestTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = cells[indexPath.row]
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RunTestTableViewCell
        cell.delegate = self
        let row = Int(indexPath.row)
        if !cellDataStore.indices.contains(row) {
            cell.configureCell(testElement: testElements[indexPath.row], rowNumber: row)
        } else {
            
        }
        return cell

    }
    
//    func configureCell(testElement: TestElement, rowNumber: Int, cell:UITableViewCell) {
//
//        //        cellDataStore[99] = [.blank, .blank, .blank, .blank, .blank, .blank]
//        //        cellDataStore[98] = [.blank, .blank, .blank, .blank, .blank, .blank]
//
//        //        masterRowNumber = rowNumber
//        if cellDataStore.indices.contains(rowNumber) {
//            print("Row \(Int(rowNumber)) already exists!")
//        } else {
//            print("Creating data for row \(rowNumber)")
//        }
//
//
//        tableTestWord.text = testElement.testWord
//        maxScore = testElement.testPhonemes.count
//        score = maxScore
//        tableTestScore.text = "\(score)/\(maxScore)"
//
//
//        if testElement.testPhonemes.count > 0 {
//            for i in  0 ..< phonemeButtonCount {
//
//                var phoneme = ""
//                //               phonemeButton = UIButton()
//                if i >= testElement.testPhonemes.count {
//                    phoneme = ""
//                    if cellDataStore.indices.contains(rowNumber) && phonemeStatuses.count == 6 {
//                        //                            print("Here's what I found for row \(rowNumber) \(cellDataStore[rowNumber])")
//                        phonemeStatuses = cellDataStore[rowNumber]
//                    } else {
//                        if phonemeStatuses.indices.contains(i) {
//                            //                                phonemeStatuses[i] = .blank
//                        } else {
//                            phonemeStatuses.append(.blank)
//                        }
//                    }
//
//                    //                    phonemeStatuses[i] = .blank
//                } else {
//                    phoneme = testElement.testPhonemes[i]
//                    if cellDataStore.indices.contains(rowNumber) && phonemeStatuses.count == 6 {
//                        //                        print("Here's what I found for row \(rowNumber)")
//                        phonemeStatuses = cellDataStore[rowNumber]
//
//                    } else {
//
//                        if phonemeStatuses.indices.contains(i) {
//                            //                                phonemeStatuses[i] = .correct
//                        } else {
//                            phonemeStatuses.append(.correct)
//                        }
//                    }
//
//                }
//                //               cellDataStore[rowNumber] = phonemeStatuses
//                configureButton(button: phonemeButtons[i], title: phoneme, status: phonemeStatuses[i], row: rowNumber, index: i)
//            }
//            if !cellDataStore.indices.contains(rowNumber) {
//                cellDataStore.append(phonemeStatuses)
//                print("CC1: Adding \(rowNumber) as a new row)")
//            } else {
//                print("These are the current phonemes \(phonemeStatuses)")
//                cellDataStore[rowNumber] = phonemeStatuses
//                print("CC1: Updating \(rowNumber))")
//
//            }
//            print("first write of row \(rowNumber)")
//
//        }
//        //        cellStatus.append(phonemeStatuses)
//        //        cellDataStore = [rowNumber:phonemeStatuses]
//        //        print("Trying to add key \(Int(rowNumber)) and value \(phonemeStatuses)")
//        //        if !cellDataStore.indices.contains(rowNumber) {
//        //            cellDataStore.append(phonemeStatuses)
//        //            print("CC2: Adding \(rowNumber) as a new row)")
//        //        } else {
//        //            cellDataStore[rowNumber] = phonemeStatuses
//        //            print("CC2: Updating \(rowNumber)")
//        //
//        //        }
//        //        print("second write of row \(rowNumber)")
//        //        print("The current data for row \(rowNumber) is \(cellDataStore[rowNumber])")
//        //        print("Dictionary is \(cellDataStore)")
//    }
    
    

    
}

extension RunTestTableViewController: CellToControllerDelegate {
    
    
}
