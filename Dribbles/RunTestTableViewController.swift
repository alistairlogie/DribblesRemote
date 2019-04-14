//
//  RunTestTableViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/23/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class RunTestTableViewController: UIViewController, CellToTableDelegate {
    
    var timer = Timer()
    var timeRemaining = 11 {
        didSet {
            if timeRemaining == 1 {
                countdownTimer.text = "\(timeRemaining) second"
            } else {
                countdownTimer.text = "\(timeRemaining) seconds"
            }
        }
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
    var phonemeButtonCount = 6
    var tableCellStore = [TableCellData]()
    var cumulativeMaxScore = 0
    var cumulativeScore = 0 {
        didSet {
            totalTestScore.text = "\(cumulativeScore)/\(cumulativeMaxScore)"
        }
    }
    var endOfTestSet = false
    var currentTag = 0
    var currentRow = 0

    @IBOutlet weak var runTestTable: UITableView!
    
    @IBOutlet weak var countdownTimer: UILabel!
    
    @IBOutlet weak var totalTestScore: UITextField!    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.runTestTable.rowHeight = 61
        self.title = selectedTest
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
        if let testFileListPath = Bundle.main.path(forResource: selectedTest, ofType: "txt") {
            if let testFileData = try? String(contentsOfFile: testFileListPath) {
                testLines = testFileData.components(separatedBy: "\n")

                for (_, testLine) in testLines.enumerated() {
                    if let newElement = decomposeTestLines(wholeTestLine: testLine) {
                        createTableCellData(testElement: newElement)
                    }
                }
            }
        } else {
            testLines = ["no tests found"]
        }
        runTestTable.reloadData()
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timerRunning()
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
    
    @objc func timerRunning() {
        timeRemaining -= 1
//        countdownTimer.text = "\(timeRemaining) seconds"
        if timeRemaining < 4  {
            
            if timeRemaining < 1 {
                timer.invalidate()
                countdownTimer.text = "Time's Up!"
                self.countdownTimer.layer.removeAllAnimations()
            } else {
//                UIView.animate(withDuration: 4.0, animations: {
//                    self.countdownTimer.layer.backgroundColor = UIColor.red.cgColor
////                    self.runTestTable.layer.backgroundColor = UIColor.red.cgColor
//                })
                UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.repeat, UIView.AnimationOptions.autoreverse], animations: {
                    self.countdownTimer.layer.backgroundColor = UIColor.init(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor
                }, completion: nil)
            }
//            countdownTimer.textColor = .red
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
    
    func createTableCellData(testElement: TestElement) {
        let newTableCell = TableCellData()
        newTableCell.word = testElement.testWord
        newTableCell.testPhonemes = testElement.testPhonemes
        newTableCell.maxScore = newTableCell.testPhonemes.count
        newTableCell.score = newTableCell.maxScore
        
        if newTableCell.testPhonemes.count > 0 {
            for i in  0 ..< phonemeButtonCount {
                if i >= testElement.testPhonemes.count {
                        if !newTableCell.buttonStates.indices.contains(i) {
                            newTableCell.buttonStates.append(.blank)
                            newTableCell.enabledStatuses.append(.disabled)
                        }
                    } else {                    
                        if !newTableCell.buttonStates.indices.contains(i) {
                            newTableCell.buttonStates.append(.correct)
                            newTableCell.enabledStatuses.append(.enabled)
                        }
                    }
                    
                }

            }
        cumulativeMaxScore += newTableCell.maxScore
        cumulativeScore += newTableCell.score
        tableCellStore.append(newTableCell)
    }
    
    func buttonInCellTapped(cell: RunTestTableViewCell, tag: Int, row: Int) {
        print("A button was tapped at tag \(tag) and row \(row)")
        switch tableCellStore[row].buttonStates[tag] {
        case .correct:
            tableCellStore[row].buttonStates[tag] = .incorrect
            tableCellStore[row].score -= 1
            cumulativeScore -= 1
        case .incorrect:
            tableCellStore[row].buttonStates[tag] = .endOfTest
            endOfTest(tag: tag , row: row)
//            cumulativeScore += 1
        case .endOfTest:
            tableCellStore[row].buttonStates[tag] = .correct
            tableCellStore[row].score += 1
            cumulativeScore += 1
            reverseEndOfTest(tag: tag, row: row)
        default:
            return
        }
        runTestTable.reloadData()
    }
    
    func endOfTest(tag: Int, row: Int) {
        for phonemeIndex in tag + 1 ..< tableCellStore[row].testPhonemes.count {
            if tableCellStore[row].buttonStates[phonemeIndex] == .correct {
                tableCellStore[row].buttonStates[phonemeIndex] = .incorrect
                tableCellStore[row].enabledStatuses[phonemeIndex] = .disabled
                tableCellStore[row].score -= 1
                cumulativeScore -= 1
            } else {
                tableCellStore[row].enabledStatuses[phonemeIndex] = .disabled
            }
        }
        for rowIndex in row + 1 ..< tableCellStore.count {
            for phonemeIndex in 0 ..< tableCellStore[rowIndex].testPhonemes.count {
                if tableCellStore[rowIndex].buttonStates[phonemeIndex] == .correct {
                    tableCellStore[rowIndex].buttonStates[phonemeIndex] = .incorrect
                    tableCellStore[rowIndex].enabledStatuses[phonemeIndex] = .disabled
                    tableCellStore[rowIndex].score -= 1
                    cumulativeScore -= 1
                } else {
                    
                    tableCellStore[rowIndex].enabledStatuses[phonemeIndex] = .enabled
                }
            }
        }
    }
    
    func reverseEndOfTest(tag: Int, row: Int) {
        for phonemeIndex in tag + 1 ..< tableCellStore[row].testPhonemes.count {
                tableCellStore[row].buttonStates[phonemeIndex] = .correct
                tableCellStore[row].enabledStatuses[phonemeIndex] = .enabled
                tableCellStore[row].score += 1
                cumulativeScore += 1
        }
    
    for rowIndex in row + 1 ..< tableCellStore.count {
            for phonemeIndex in 0 ..< tableCellStore[rowIndex].testPhonemes.count {
                if tableCellStore[rowIndex].buttonStates[phonemeIndex] == .correct {
                    tableCellStore[rowIndex].buttonStates[phonemeIndex] = .incorrect
                    tableCellStore[rowIndex].enabledStatuses[phonemeIndex] = .disabled
                    tableCellStore[rowIndex].score -= 1
                    cumulativeScore -= 1
                } else {
                    tableCellStore[rowIndex].buttonStates[phonemeIndex] = .correct
                    tableCellStore[rowIndex].enabledStatuses[phonemeIndex] = .enabled
                    tableCellStore[rowIndex].score += 1
                    cumulativeScore += 1
                }
            }
        }
    }
    
}



extension RunTestTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RunTestTableViewCell
        cell.delegate = self
        let row = Int(indexPath.row)
            print("Calling configureCell with \(tableCellStore[indexPath.row])")
        
        cell.configureCell(tableCellData: tableCellStore[indexPath.row], rowNumber: row)
        return cell
    }
}

