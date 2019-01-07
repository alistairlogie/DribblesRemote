//
//  RunTestViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/15/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class RunTestViewController: UIViewController {
    
    var selectedTest = String()
    var currentStudent = String()
    var container: NSPersistentContainer!
    var todaysDate = Date()
    var updatedResults = [TestEvent]()
    var testLines = [String]()
    var testLine = String()
    var testElement = TestElement()
    var testElements = [TestElement]()
    

    
    @IBOutlet weak var score: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        addDummyValues()
        
        
        self.title = selectedTest
        print(currentStudent)
        print(selectedTest)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit Results", style: .plain, target: self, action: #selector(submitTestResultPressed(_:)))
//        print(container.viewContext)
        if let testFileListPath = Bundle.main.path(forResource: selectedTest, ofType: "txt") {
            if let testFileData = try? String(contentsOfFile: testFileListPath) {
                    testLines = testFileData.components(separatedBy: "\n")
//                    print("\(testLines.count) found.")
                for (_, testLine) in testLines.enumerated() {
                    if let newElement = decomposeTestLines(wholeTestLine: testLine) {
//                        print("New element is \(newElement)")
                        testElements.append(newElement)
//                        print("Final results \(testElements[index].testWord, testElements[index].testPhonemes)")
                    }
                }
            }
        } else {
            testLines = ["no tests found"]
        }
    }
        
        // Do any additional setup after loading the view.
    
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
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
    

    @objc func submitTestResultPressed(_ sender: UIBarButtonItem) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let todaysDate = Date()
        
        //let numberFormatter = NumberFormatter()
        //numberFormatter.numberStyle = .decimal
        
        let testScore = score.text
        let testScoreFloat = NSString(string: testScore!).floatValue
        
//        print(container)
        let testEvent = TestEvent(context: PersistenceService.context)
            testEvent.testType = selectedTest
            testEvent.student = currentStudent
            testEvent.date = todaysDate as NSDate
            testEvent.score = testScoreFloat
//          print(testEvent)
//          updatedResults.append(testEvent)
        
        PersistenceService.saveContext()
        
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "StudentDetail") as? StudentDetailViewController {
//            navigationController?.pushViewController(vc, animated: true)
//
//            vc.studentName = currentStudent
//            vc.updatedResults = previousResults
        self.navigationController?.popViewController(animated: true)
    }
        
    
    
    
    func decomposeTestLines(wholeTestLine: String) -> TestElement? {
        let testChunks = wholeTestLine.components(separatedBy: ",")
        //let testElement = TestElement()
//        print("testChunks \(testChunks)")
        //clear out the arrays
        testElement.testWord = ""
        testElement.testPhonemes.removeAll()
        //testElement.testWord = testChunks[0]
//        print(testChunks.count)
        // make sure it's not a blank line
        if testChunks.count > 1 {
//            print("\(testChunks.count) is apparently greater than 1")
            for (index, chunk) in testChunks.enumerated() {

                if chunk != "" {
                    //if it's the first chunk, set that as the test word
                    if index == 0 {
                        testElement.testWord = chunk
//                    print("Test word is \(testElement.testWord)")
                        
                    // if it's the second chunk or higher, add it to the phonemes array
                    } else {
                        testElement.testPhonemes.append(chunk)
                    }
                }
            }
//            print("Test element is \(testElement.testWord, testElement.testPhonemes)")
//            let returnedElement = testElement
//            print("Returned element is \(returnedElement)")
//            print("Returned word is \(returnedElement.testWord)")
            return testElement
        } else {
            return nil
        }
    }
    
    func addDummyValues() {
        selectedTest = "Benchmark 1 - Phoneme Segmentation Fluency"
        currentStudent = "Laurie Jones"
    }
}


