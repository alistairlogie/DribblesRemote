//
//  StundentDetailViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/14/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class StudentDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var studentName = ""
    var testTypes = [String]()
    var selectedTest = String()
    var previousResults = [TestEvent]()
    var flowLayout = UICollectionViewFlowLayout()
    var testEventPredicate = NSPredicate()
    
    
    
   
    @IBOutlet weak var testPicker: UIPickerView!
    @IBOutlet var previousResultsCollectionView: UICollectionView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the title of the screen to the selected student name
        self.title = studentName
        //Try and retrieve the list of test types and if found, add them to the testTypes array
        if let testTypesListPath = Bundle.main.path(forResource: "DribblesTestList", ofType: "txt") {
            if let testTypesListEntries = try? String(contentsOfFile: testTypesListPath) {
                testTypes = testTypesListEntries.components(separatedBy: "\n")
            }
        } else {
            testTypes = ["no tests found"]
        }
        
        //Set this VC as the delegate for the Picker
        self.testPicker.delegate = self
        self.testPicker.dataSource = self
        loadSavedData()

        previousResultsCollectionView.dataSource = self
        previousResultsCollectionView.delegate = self

        flowLayout = ColumnFlowLayout()
        previousResultsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        //view.addSubview(previousResultsCollectionView)

        previousResultsCollectionView.register(TestEventCell.self, forCellWithReuseIdentifier: "TestEventCell")


        previousResultsCollectionView.reloadData()
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 //       print(container)
        if segue.destination is RunTestViewController {
            let vc = segue.destination as? RunTestViewController
            if selectedTest == "" {
                vc?.selectedTest = testTypes[0]
            } else {
                vc?.selectedTest = selectedTest
            }
            
            vc?.currentStudent = studentName
            vc?.updatedResults = previousResults
  //          vc?.container = container
        }
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Previous results is \(previousResults.count)")
        return previousResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Adding cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestEventCell", for: indexPath) as! TestEventCell
        let result = previousResults[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateStringValue = formatter.string(from: (result.date as NSDate) as Date)
        cell.testDate.text = dateStringValue
//        cell.testDate?.text = formatter(result.date)
        cell.testType?.text = result.testType
        cell.testScore.text = String(result.score)
//        cell.testDate.text = "2018-09-12"
//        cell.testType.text = "Benchmark 1 - Phoneme Segmentation Fluency"
//        cell.testScore.text = "22"
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
            print("Got \(previousResults.count) results")
            
            previousResultsCollectionView.reloadData()
            
        } catch {
            print("Fetch failed")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //viewDidLoad()
        
        print("View will appear called")
        self.loadSavedData()
        self.testPicker.delegate = self
        self.testPicker.dataSource = self
        
        //        print("in sdvc\(PersistenceService.context)")
        previousResultsCollectionView.dataSource = self
        previousResultsCollectionView.delegate = self
        
        flowLayout = ColumnFlowLayout()
        previousResultsCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        //view.addSubview(previousResultsCollectionView)
        
        previousResultsCollectionView.register(TestEventCell.self, forCellWithReuseIdentifier: "TestEventCell")
        
        //        self.collectionView.dataSource = self
        //        self.collectionView.delegate = self
        
        //previousResultsCollectionView.reloadSections(IndexSet[0])
        previousResultsCollectionView.reloadData()
        //view.addSubview(previousResultsCollectionView)
        
        
        
//        self.previousResultsCollectionView .reloadItems(at: [self.previousResultsCollectionView!.indexPathsForVisibleItems])
        self.previousResultsCollectionView.reloadData()
        self.previousResultsCollectionView.collectionViewLayout .invalidateLayout()
        
        
    }
    
   
    
    @IBAction func startTestPressed(_ sender: UIButton) {
        
        
    }
    
}
