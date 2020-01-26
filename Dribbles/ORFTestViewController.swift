//
//  ORFTestViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 7/26/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class ORFTestViewController: UIViewController, ORFCellToTableDelegate {

    var timer = Timer()
    // Setting the length of the test in seconds
    var testLength = 60
    // Counter of time remaining with property observer to update the label
    var timeRemaining = 60 {
        didSet {
            if timeRemaining == 1 {
                countdownTimer.text = "\(timeRemaining) second"
            } else {
                countdownTimer.text = "\(timeRemaining) seconds"
            }
        }
    }
    
    // Passed from the previous screen
    var selectedTest = String()
    var currentStudent = String()
    var updatedResults = [TestEvent]()
    var container: NSPersistentContainer!
    var todaysDate = Date()
    var testLines = [String]()
    var testLine = String()
    var testElement = ORFTestElement()
    var testElements = [ORFTestElement]()
    
    var tableCellStore = [ORFTableCellData]()
    var validChunkCount = 0
    
    var wordButtonCount = 16
    
    var endOfTestSet = false
    
    var currentTag = 0
    var currentRow = 0
    var isPaused = false
    var pauseTime = 0
    var alreadyStarted = false
    
    var cumulativeMaxScore = 0
    // Current total score with property observer to update the total score label
    var cumulativeScore = 0 {
        didSet {
            totalTestScore.text = "\(cumulativeScore)/\(cumulativeMaxScore)"
        }
    }
    
    @IBOutlet weak var runTestTable: UITableView!
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var totalTestScore: UITextField!
    @IBOutlet var startPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.runTestTable.rowHeight = 61
        self.title = selectedTest
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
        startPauseButton.layer.cornerRadius = 10
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
        runTestTable.alpha = 0.3
        runTestTable.isUserInteractionEnabled = false

        // Do any additional setup after loading the view.
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                let ac = UIAlertController(title: "Database error", message: "We were unable to save the test data.", preferredStyle: .alert)
                _ = ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                    return
                })
                self.present(ac, animated: true)
            }
        }
    }
    
    @objc func submitTestResultPressed(_ sender: UIBarButtonItem) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let todaysDate = Date()
        let testScore = totalTestScore.text
        let testScoreFloat = NSString(string: testScore!).floatValue
        let cumulativeScoreFloat = Float(cumulativeScore)
        let cumulativeMaxScoreFloat = Float(cumulativeMaxScore)
        let testPercentageCorrectFloat = (cumulativeScoreFloat / cumulativeMaxScoreFloat) * 100
//        let testPercentageCorrect = String((cumulativeScore / cumulativeMaxScore) * 100)
//        let testPercentageCorrectFloat = NSString(string: testPercentageCorrect).floatValue
        let testEvent = TestEvent(context: PersistenceService.context)
        testEvent.testType = selectedTest
        testEvent.student = currentStudent
        testEvent.percentageCorrect = testPercentageCorrectFloat
        testEvent.date = todaysDate as NSDate
        testEvent.score = testScoreFloat
        
        PersistenceService.saveContext()
        
        self.navigationController?.popViewController(animated: true)
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
                UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.repeat, UIView.AnimationOptions.autoreverse], animations: {
                    self.countdownTimer.layer.backgroundColor = UIColor.init(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor
                }, completion: nil)
            }
            
        }
        
    }
    
    func decomposeTestLines(wholeTestLine: String) -> ORFTestElement? {
        // break the line into chunks delimited by commas
        let testChunks = wholeTestLine.components(separatedBy: "|")
        // clear out any existing test words
        testElement.testWords.removeAll()
        
//        while testChunks.count < 15 {
//            testChunks.append("")
//        }
        
        if testChunks.count > 0 {
            
            for (_, chunk) in testChunks.enumerated() {
                if chunk != "" {
                    testElement.testWords.append(chunk)
                }
                
            }
//            batchScore += validChunkCount
            return testElement
        } else {
            return nil
        }
    }
    
    func createTableCellData(testElement: ORFTestElement) {
        let newTableCell = ORFTableCellData()
        newTableCell.testWords = testElement.testWords
        newTableCell.maxScore = newTableCell.testWords.count
        newTableCell.score = newTableCell.maxScore
        
        
        if newTableCell.testWords.count > 0 {
            // cycle through all 13 button settings
            for i in  0 ..< wordButtonCount {
                if i >= testElement.testWords.count {
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
            cumulativeMaxScore += newTableCell.maxScore
            cumulativeScore += newTableCell.score
            tableCellStore.append(newTableCell)
        }
//        cumulativeMaxScore += newTableCell.maxScore
//        cumulativeScore += newTableCell.score
//        tableCellStore.append(newTableCell)
//        batchScore = 0
    }
    
    func buttonInCellTapped(cell: ORFTestTableViewCell, tag: Int, row: Int) {
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
        
        for wordIndex in tag + 1 ..< tableCellStore[row].testWords.count {
            //disables all the buttons after the end cell
            if tableCellStore[row].buttonStates[wordIndex] == .correct {
                tableCellStore[row].buttonStates[wordIndex] = .incorrect
                tableCellStore[row].enabledStatuses[wordIndex] = .disabled
                tableCellStore[row].score -= 1
                cumulativeScore -= 1
            } else {
                tableCellStore[row].enabledStatuses[wordIndex] = .disabled
            }
        }
        for rowIndex in row + 1 ..< tableCellStore.count {
            for wordIndex in 0 ..< tableCellStore[rowIndex].testWords.count {
                switch tableCellStore[rowIndex].buttonStates[wordIndex] {
                case .correct:
                    tableCellStore[rowIndex].buttonStates[wordIndex] = .incorrect
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .disabled
                    tableCellStore[rowIndex].score -= 1
                    cumulativeScore -= 1
                case .incorrect:
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .enabled
                case .blank:
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .enabled
                case .endOfTest:
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .enabled
                }
                
            }
        }
    }
    
    func reverseEndOfTest(tag: Int, row: Int) {
        for wordIndex in tag + 1 ..< tableCellStore[row].testWords.count {
            if tableCellStore[row].buttonStates[wordIndex] == .blank {
                tableCellStore[row].buttonStates[wordIndex] = .blank
                tableCellStore[row].enabledStatuses[wordIndex] = .disabled
            } else {
                tableCellStore[row].buttonStates[wordIndex] = .correct
                tableCellStore[row].enabledStatuses[wordIndex] = .enabled
                tableCellStore[row].score += 1
                cumulativeScore += 1
            }
            
        }
        
        for rowIndex in row + 1 ..< tableCellStore.count {
            for wordIndex in 0 ..< tableCellStore[rowIndex].testWords.count {
                switch tableCellStore[rowIndex].buttonStates[wordIndex] {
                case .correct:
                    tableCellStore[rowIndex].buttonStates[wordIndex] = .incorrect
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .disabled
                    tableCellStore[rowIndex].score -= 1
                    cumulativeScore -= 1
                case .incorrect:
                    tableCellStore[rowIndex].buttonStates[wordIndex] = .correct
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .enabled
                    tableCellStore[rowIndex].score += 1
                    cumulativeScore += 1
                case .blank:
                    tableCellStore[rowIndex].buttonStates[wordIndex] = .blank
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .disabled
                case .endOfTest:
                    tableCellStore[rowIndex].buttonStates[wordIndex] = .correct
                    tableCellStore[rowIndex].enabledStatuses[wordIndex] = .enabled
                    tableCellStore[rowIndex].score += 1
                    cumulativeScore += 1
                }
               
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func startTimerClicked(_ sender: UIButton) {
        if alreadyStarted == true {
            if isPaused == true {
                startPauseButton.backgroundColor = .clear
                startPauseButton.alpha = 0.1
                startPauseButton.titleLabel?.text = ""
                runTestTable.isUserInteractionEnabled = true
                runTestTable.alpha = 1
                runTimer()
                print("starting again because i think the button was pressed")
                isPaused = false
                
            } else {
                print("paused")
                startPauseButton.backgroundColor = .cyan
                startPauseButton.setTitleColor(.cyan, for: .normal)
                timer.invalidate()
                isPaused = true
                startPauseButton.alpha = 0.5
                runTestTable.isUserInteractionEnabled = false
                runTestTable.alpha = 0.3
                
            }
        } else {
            startPauseButton.titleLabel?.text = ""
            startPauseButton.backgroundColor = .clear
            startPauseButton.alpha = 0.1
            timeRemaining = testLength
            runTestTable.isUserInteractionEnabled = true
            runTestTable.alpha = 1
            runTimer()
            alreadyStarted = true
            isPaused = false
        }
    }
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }

}

extension ORFTestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ORFTestTableViewCell
        cell.delegate = self
        let row = Int(indexPath.row)
        
        cell.configureCell(tableCellData: tableCellStore[indexPath.row], rowNumber: row)
        return cell
    }
}
