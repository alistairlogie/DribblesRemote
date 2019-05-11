//
//  StundentDetailViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/14/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class previousResultsTableViewCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var testTypeLabel: UILabel!
}

class StudentDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {

    var studentName = ""
    var testTypes = [String]()
    var testList = [String]()
    var selectedTest = String()
    var previousResults = [TestEvent]()
    
    var testEventPredicate = NSPredicate()
    
    
    
   
    @IBOutlet weak var testPicker: UIPickerView!
    
    @IBOutlet var previousResultsTableView: UITableView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testPicker.dataSource = self
        testPicker.delegate = self
        //Set the title of the screen to the selected student name
        self.title = studentName
        //Try and retrieve the list of test types and if found, add them to the testTypes array
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        for item in items {
            if item.hasSuffix(".txt"){
                let testName = String(item.split(separator: ".").first!)
                testList.append(testName)
            }
            
        }
// sorting the test list before it's presented to the user
        testTypes = testList.sorted()

        selectedTest = testTypes[0]
        previousResultsTableView.delegate = self
        previousResultsTableView.dataSource = self

    }

    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //create the correct number of rows in the picker
        return testTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //set the row title to the name of the test
        return testTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTest = testTypes[row]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! previousResultsTableViewCell
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let dateString = formatter.string(from: (previousResults[indexPath.row].date as Date))
        
        cell.dateLabel.text = dateString
        cell.testTypeLabel.text = previousResults[indexPath.row].testType
        cell.scoreLabel.text = String(previousResults[indexPath.row].score)
        return cell
    }
    
    
    func loadSavedData() {
        //clear out the previousResults array
        previousResults.removeAll()
        
        //create the fetch request with the required filter (student = currently selected studentName) and sort criteria
        let request =  TestEvent.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        let filter = studentName
        testEventPredicate = NSPredicate(format: "student == %@", filter)
        request.predicate = testEventPredicate
        
        
        do {
            //try and load the results of the request into the previousResults array
            previousResults = try PersistenceService.context.fetch(request)
            previousResultsTableView.reloadData()
            
            
            
        } catch {
            let ac = UIAlertController(title: "Database error", message: "We were unable to retrieve data from the database.", preferredStyle: .alert)
            
            _ = ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                return
            })
            self.present(ac, animated: true)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Delete test result?", message: "Are you sure? You won't be able to retrieve this data.", preferredStyle: .alert)
            
            _ = ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            })
            
            _ = ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let testEvent = self.previousResults[indexPath.row]
                PersistenceService.context.delete(testEvent)
                self.previousResults.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                PersistenceService.saveContext()
            }))
            self.present(ac, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        loadSavedData()
    }
    
   
    
    @IBAction func startTestPressed(_ sender: UIButton) {
//        vc.studentName = students[indexPath.row].name
        if Bundle.main.path(forResource: selectedTest, ofType: "txt") != nil {
            if selectedTest.contains("Phoneme") {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "RunTestTable") as? RunTestTableViewController {
                    navigationController?.pushViewController(vc, animated: true)
                    if selectedTest == "" {
                        vc.selectedTest = testTypes[0]
                    } else {
                        vc.selectedTest = selectedTest
                    }
                    
                    vc.currentStudent = studentName
                    vc.updatedResults = previousResults
                }
            }
            if selectedTest.contains("Nonsense") {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "NWFTestTable") as? NWFTestViewController {
                    navigationController?.pushViewController(vc, animated: true)
                    if selectedTest == "" {
                        vc.selectedTest = testTypes[0]
                    } else {
                        vc.selectedTest = selectedTest
                    }
                    
                    vc.currentStudent = studentName
                    vc.updatedResults = previousResults
                }
            }
        } else {
            let ac = UIAlertController(title: "Test Unavailable", message: "This test is currently not available. Please try again later", preferredStyle: .alert)
            
            _ = ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                return
            })
            self.present(ac, animated: true)
        }
        
        
        
    }
    
}
