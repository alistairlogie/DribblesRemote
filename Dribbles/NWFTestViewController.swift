//
//  NWFTestViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 4/14/19.
//  Copyright © 2019 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class NWFTestViewController: UIViewController {
    
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
    
    var selectedTest = "Benchmark 1 - Nonsense Word Fluency"
    var currentStudent = "Bob Jones"
    var container: NSPersistentContainer!
    var todaysDate = Date()
    var updatedResults = [TestEvent]()
    var testLines = [String]()
    var testLine = String()
    var batchElement = TestElement()
    var testElement = TestElement()
    var testElements = [TestElement]()
    var phonemeButtonCount = 3
    var validChunkCount = 0
    var batchCount = 1
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
    
    
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var runTestTable: UITableView!
    @IBOutlet weak var totalTestScore: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.runTestTable.rowHeight = 61
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
        
        if let testFileListPath = Bundle.main.path(forResource: selectedTest, ofType: "txt") {
            if let testFileData = try? String(contentsOfFile: testFileListPath) {
                testLines = testFileData.components(separatedBy: "\n")
                
                for (_, testLine) in testLines.enumerated() {
                    if let newElement = decomposeTestLines(wholeTestLine: testLine) {
                        if batchCount == 1 {
                            batchElement = newElement
                        }
                        if batchCount > 1 && batchCount < 5 {
                            batchElement.testPhonemes.append(contentsOf: newElement.testPhonemes)
                        }
                        if batchCount == 5 {
                            batchElement.testPhonemes.append(contentsOf: newElement.testPhonemes)
                            createTableCellData(testElement: batchElement)
                            batchCount = 0
                        }
                        batchCount += 1
                    }
                }
            }
        } else {
            testLines = ["no tests found"]
        }
        
        runTestTable.reloadData()

        // Do any additional setup after loading the view.
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

        }
        
    }
    
    func decomposeTestLines(wholeTestLine: String) -> TestElement? {
        var testChunks = wholeTestLine.components(separatedBy: ",")
        validChunkCount = testChunks.count
        testElement.testWord = ""
        testElement.testPhonemes.removeAll()
        while testChunks.count < 3 {
            testChunks.append("")
        }
        
        if testChunks.count > 1 {

            for (index, chunk) in testChunks.enumerated() {
                testElement.testPhonemes.append(chunk)
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
        newTableCell.maxScore = validChunkCount
        newTableCell.score = validChunkCount
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NWFTestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NFWTestTableViewCell
        return cell
    }
}