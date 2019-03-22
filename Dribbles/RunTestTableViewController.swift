//
//  RunTestTableViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/23/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData




class RunTestTableViewController: UIViewController, RunTestTableViewCellDelegate  {
    
    
    
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
    
//    var cells = [RunTestTableViewCell]()
    
    
    
//    var phonemeButtons = [UIButton]()
//    var buttons = [UIButton]()
//    var currentButton = UIButton()
//    var currentButtons = [UIButton]()
    //var tappedPhonemeButtons = [UIButton]()
    
    
    @IBOutlet weak var runTestTable: UITableView!
    @IBOutlet weak var score: UITextField!
    
    //var phonemeButtons = [UIButton]()
    
    
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
        let testScore = score.text
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
 
    func buttonTapped(cell: RunTestTableViewCell, buttonIndex: Int, button: UIButton) {
        if let indexPath = runTestTable.indexPath(for: cell) {
            selectedButtonRow = indexPath.row
            
            cell.updateButton(row: selectedButtonRow, buttonIndex: buttonIndex, button: button)
        }
    }
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
        cell.configureCell(testElement: testElements[indexPath.row], rowNumber: row)
        return cell

    }
    

    
}

extension RunTestTableViewController: UITableViewDelegate {
    
    
}
