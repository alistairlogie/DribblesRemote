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
    var phonemeStatuses = [PhonemeStatus]()
    var tableCellStore = [TableCellData]()

    @IBOutlet weak var runTestTable: UITableView!
 
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                        }
                    } else {                    
                        if !newTableCell.buttonStates.indices.contains(i) {
                            newTableCell.buttonStates.append(.correct)
                        }
                    }
                    
                }

            }
        tableCellStore.append(newTableCell)
    }
    
    func buttonInCellTapped(cell: RunTestTableViewCell, tag: Int, row: Int) {
        print("A button was tapped at tag \(tag) and row \(row)")
        if tableCellStore[row].buttonStates[tag] == .correct {
            tableCellStore[row].buttonStates[tag] = .incorrect
        } else {
            if tableCellStore[row].buttonStates[tag] == .incorrect {
                tableCellStore[row].buttonStates[tag] = .correct
            }
        }
        runTestTable.reloadData()
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

