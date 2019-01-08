//
//  RunTestTableViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/23/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData




class RunTestTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var selectedTest = String()
    var currentStudent = String()
    var container: NSPersistentContainer!
    var todaysDate = Date()
    var updatedResults = [TestEvent]()
    var testLines = [String]()
    var testLine = String()
    var testElement = TestElement()
    var testElements = [TestElement]()
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
       
        
        runTestTable.delegate = self
        runTestTable.dataSource = self
        self.title = selectedTest
        print(currentStudent)
        print(selectedTest)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
        if let testFileListPath = Bundle.main.path(forResource: selectedTest, ofType: "txt") {
            if let testFileData = try? String(contentsOfFile: testFileListPath) {
                testLines = testFileData.components(separatedBy: "\n")
                //                    print("\(testLines.count) found.")
                for (index, testLine) in testLines.enumerated() {
                    if let newElement = decomposeTestLines(wholeTestLine: testLine) {
                       testElements.append(newElement)
                    }
                }
            }
        } else {
            testLines = ["no tests found"]
        }
        
//        for subview in runTestTable.subviews where subview.tag == 1001 {
//            let btn = subview as! UIButton
//            phonemeButtons.append(btn)
//            btn.addTarget(self, action: #selector(phonemeTapped), for: .touchUpInside)
//
//        }
//
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RunTestTableViewCell
        
        let row = Int(indexPath.row)
        cell.configureCell(testElement: testElements[indexPath.row], rowNumber: row)
        //print("There are \(testElements[indexPath.row].testPhonemes.count) buttons")
        
        
        //cell.tableTestWord.text = testElements[indexPath.row].testWord
        
//        if testElements[indexPath.row].testPhonemes.count > 0 {
//
//            for i in  0 ..< testElements[indexPath.row].testPhonemes.count {
//                print("Number of phonemes is \(testElements[indexPath.row].testPhonemes.count)")
//                print("got in here")
//                let phoneme = testElements[indexPath.row].testPhonemes[i]
//                print("Phoneme number \(i) is \(phoneme)")
//                currentButton.setTitle(phoneme, for: .highlighted)
//                if let currentButtonTitle = currentButton.currentTitle {
//                    print(currentButtonTitle)
//                }
//                let rowNum = (indexPath.row + 1) * 1000
//                let tag = rowNum + i + 1
//                currentButton.tag = tag
////                currentButton.addTarget(self, action: #selector(phonemeButtonSelected(_:)), for: .touchUpInside)
//
//                currentButtons.append(currentButton)
//
//
//            }
//        }
//        cell.tableTestScore.text = "\(testElements[indexPath.row].testPhonemes.count)/\(testElements[indexPath.row].testPhonemes.count)"
        
//        cell.collectionOfButtons = currentButtons
        
//        if cell.collectionOfButtons == "" {
//            print("Found a blank phoneme")
//            buttons[i].isUserInteractionEnabled = false
//        } else {
//            print("doing this bit")
//            cell.collectionOfButtons?[i].isUserInteractionEnabled = true
//            cell.collectionOfButtons?[i].backgroundColor = UIColor.green
//        }
        print(cell.tableTestWord)
        print(cell.tableTestScore)
        print(cell.collectionOfButtons)
        
        
        return cell
    }

    
//    @IBAction func phonemeButtonTapped(_ sender: UIButton) {
//        print("button tapped")
//        print("button tag \(sender.tag)")
//        
//    }
//    
//    @objc func phonemeButtonSelected(_ sender: UIButton) {
//        print("Button tage \(sender.tag)")
//    }


}
