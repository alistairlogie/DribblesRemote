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
    
    var container: NSPersistentContainer!
    var todaysDate = Date()
    var updatedResults = [TestEvent]()
    var testLines = [String]()
    var testLine = String()
    var testElement = TestElement()
    var testElements = [TestElement]()
    // Max number of phonemes that can be in a test word
    var phonemeButtonCount = 6
    var tableCellStore = [TableCellData]()
    var itemsCompleted = 0
    // This value will be set depending on the total number of phonemes in the test
    var cumulativeMaxScore = 0
    // Current total score with property observer to update the total score label
    var cumulativeScore = 0 {
        didSet {
            totalTestScore.text = "\(cumulativeScore)/\(cumulativeMaxScore)"
        }
    }
    // If a final phoneme has been selected to mark the end of the test this will be true
    var endOfTestSet = false
    
    var currentTag = 0
    var currentRow = 0
    var isPaused = false
    var pauseTime = 0
    var alreadyStarted = false

    @IBOutlet weak var runTestTable: UITableView!
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var totalTestScore: UITextField!
    @IBOutlet var startPauseButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alreadyStarted = false
        self.runTestTable.rowHeight = 61
        startPauseButton.layer.cornerRadius = 10
        self.title = selectedTest
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
        // Look for the textfile for the selected test
        if let testFileListPath = Bundle.main.path(forResource: selectedTest, ofType: "txt") {
            // grab the data from the test text file
            if let testFileData = try? String(contentsOfFile: testFileListPath) {
                // separate the file contents by newlines
                testLines = testFileData.components(separatedBy: "\n")

                for (_, testLine) in testLines.enumerated() {
                    if let newElement = decomposeTestLines(wholeTestLine: testLine) {
                        // create the table cell data for this line of the text file
                        createTableCellData(testElement: newElement)
                    }
                }
            }
        } else {
            testLines = ["no tests found"]
        }
        runTestTable.reloadData()
        // start the test with the test buttons grayed out (and disabled) , to make sure the user starts the timer
        runTestTable.isUserInteractionEnabled = false
        runTestTable.alpha = 0.3
        
        
    }
    // Save the data whenever it changes
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                let ac = UIAlertController(title: "Database error", message: "We were unable to save the test data.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                    return
                })
                self.present(ac, animated: true)
            }
        }
    }
    
    @objc func timerRunning() {
        // decrement the timer by 1
        timeRemaining -= 1
        if timeRemaining < 4  {
            
            if timeRemaining < 1 {
                // If the timer has reached zero, kill the timer, put up a "Time's up" message and stop the text from flashing
                timer.invalidate()
                countdownTimer.text = "Time's Up!"
                self.countdownTimer.layer.removeAllAnimations()
            } else {
                // If there's less than four seconds left (and more than 0), flash the timer red to indicate to the user that time is running out.
                UIView.animate(withDuration: 0.5, delay: 0, options: [UIView.AnimationOptions.repeat, UIView.AnimationOptions.autoreverse], animations: {
                    self.countdownTimer.layer.backgroundColor = UIColor.init(red: 1.0, green: 0, blue: 0, alpha: 0.5).cgColor
                }, completion: nil)
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
        let itemsCompletedFloat = Float(itemsCompleted)
        let testPercentageCorrectFloat = (cumulativeScoreFloat / itemsCompletedFloat) * 100
        let testEvent = TestEvent(context: PersistenceService.context)
        testEvent.testType = selectedTest
        testEvent.student = currentStudent
        testEvent.percentageCorrect = testPercentageCorrectFloat
        testEvent.date = todaysDate as NSDate
        testEvent.score = testScoreFloat

        PersistenceService.saveContext()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // This breaks each line in the text file into the test word followed by up to 6 phonemes that make up the word
    func decomposeTestLines(wholeTestLine: String) -> TestElement? {
        // break the line into chunks delimited by commas
        let testChunks = wholeTestLine.components(separatedBy: ",")
        // clear out any existing test word
        testElement.testWord = ""
        // clear out any existing test phonemes
        testElement.testPhonemes.removeAll()

        if testChunks.count > 1 {
            // If there is more than one chunk i.e. test word plus at least one phoneme
            for (index, chunk) in testChunks.enumerated() {
                // Ignore any blank chunks
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
    
    // This sets up how the table cell looks. Even if there are fewer than 6 phonemes, all 6 buttons need to be set up.
    func createTableCellData(testElement: TestElement) {
        let newTableCell = TableCellData()
        newTableCell.word = testElement.testWord
        newTableCell.testPhonemes = testElement.testPhonemes
        newTableCell.maxScore = newTableCell.testPhonemes.count
        newTableCell.score = newTableCell.maxScore
        
        if newTableCell.testPhonemes.count > 0 {
            //  cycle through all 6 button settings
            for i in  0 ..< phonemeButtonCount {
                // If we're on a button that there is no phoneme for make it blank and disabled
                if i >= testElement.testPhonemes.count {
                        if !newTableCell.buttonStates.indices.contains(i) {
                            newTableCell.buttonStates.append(.blank)
                            newTableCell.enabledStatuses.append(.disabled)
                        }
                    // otherwise mark it as correct (the default is to assume the answer is correct) and enable the button
                    } else {                    
                        if !newTableCell.buttonStates.indices.contains(i) {
                            newTableCell.buttonStates.append(.correct)
                            newTableCell.enabledStatuses.append(.enabled)
                        }
                    }
                    
                }

            }
        // add the scores to the total score for all the rows
        cumulativeMaxScore += newTableCell.maxScore
        cumulativeScore += newTableCell.score
        // add the completed cell data to the cell data array (this is the data that will drive the UI)
        tableCellStore.append(newTableCell)
        itemsCompleted = cumulativeMaxScore
    }
    
    func buttonInCellTapped(cell: RunTestTableViewCell, tag: Int, row: Int) {
        // This rotates active buttons between three states Correct -> Incorrect -> EndOfTest
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
        itemsCompleted -= 1
        for phonemeIndex in tag + 1 ..< tableCellStore[row].testPhonemes.count {
            // disable all buttons after the end cell
            if tableCellStore[row].buttonStates[phonemeIndex] == .correct {
                tableCellStore[row].buttonStates[phonemeIndex] = .incorrect
                tableCellStore[row].enabledStatuses[phonemeIndex] = .disabled
                tableCellStore[row].score -= 1
                cumulativeScore -= 1
                itemsCompleted -= 1
            } else {
                tableCellStore[row].enabledStatuses[phonemeIndex] = .disabled
            }
        }
        for rowIndex in row + 1 ..< tableCellStore.count {
            // disable all rows below the end cell
            for phonemeIndex in 0 ..< tableCellStore[rowIndex].testPhonemes.count {
                if tableCellStore[rowIndex].buttonStates[phonemeIndex] == .correct {
                    tableCellStore[rowIndex].buttonStates[phonemeIndex] = .incorrect
                    tableCellStore[rowIndex].enabledStatuses[phonemeIndex] = .disabled
                    tableCellStore[rowIndex].score -= 1
                    cumulativeScore -= 1
                    itemsCompleted -= 1
                } else {
                    
                    tableCellStore[rowIndex].enabledStatuses[phonemeIndex] = .enabled
                }
            }
        }
    }
    
    func reverseEndOfTest(tag: Int, row: Int) {
        // back out the end of test function
        itemsCompleted += 1
        for phonemeIndex in tag + 1 ..< tableCellStore[row].testPhonemes.count {
                tableCellStore[row].buttonStates[phonemeIndex] = .correct
                tableCellStore[row].enabledStatuses[phonemeIndex] = .enabled
                tableCellStore[row].score += 1
                cumulativeScore += 1
                itemsCompleted += 1
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
    
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        // Check to see if the test has already been started
        if alreadyStarted == true {
            // If it's already been started adn the current state is paused, unpause the timer and re-enable the table
            if isPaused == true {
                startPauseButton.backgroundColor = .clear
                startPauseButton.alpha = 0.1
                startPauseButton.titleLabel?.text = ""
                runTestTable.isUserInteractionEnabled = true
                runTimer()
                 runTestTable.alpha = 1
//                print("starting again because i think the button was pressed")
                isPaused = false

            } else {
                // If the status is not paused, go a head and pause the timer, set the timer button color, and disable the table
//                print("paused")
                startPauseButton.backgroundColor = .cyan
                startPauseButton.setTitleColor(.cyan, for: .normal)
                timer.invalidate()
                isPaused = true
                runTestTable.isUserInteractionEnabled = false
                startPauseButton.alpha = 0.2

            }
        } else {
            // If the test hasn't been started, go ahead and start it
            startPauseButton.titleLabel?.text = ""
            startPauseButton.backgroundColor = .clear
            startPauseButton.alpha = 0.1
            timeRemaining = testLength
            runTestTable.isUserInteractionEnabled = true
            runTimer()
            alreadyStarted = true
            isPaused = false
             runTestTable.alpha = 1
        }
    }
    // basic function to kick off the timer
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
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
        
        cell.configureCell(tableCellData: tableCellStore[indexPath.row], rowNumber: row)
        return cell
    }
}

