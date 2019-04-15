//
//  ViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/13/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    
    var students = [Student]()
    var addStudentName:String = ""
    var testEventPredicate = NSPredicate()
    var associatedResults = [TestEvent]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadSavedData()
        tableView.reloadData()
    }

    
    
    func loadSavedData() {
        let request =  Student.createFetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            students = try PersistenceService.context.fetch(request)
            print("Got \(students.count) students")
            tableView.reloadData()
        } catch {
            let ac = UIAlertController(title: "Database error", message: "We were unable to retrieve student data from the database.", preferredStyle: .alert)
            
            _ = ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                return
            })
            self.present(ac, animated: true)
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let student = students[indexPath.row]
        cell.textLabel?.text = student.name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.destination is StudentDetailViewController {
//            let vc = segue.destination as? StudentDetailViewController
//            vc?.container = container
//            
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "StudentDetail") as? StudentDetailViewController {

                vc.studentName = students[indexPath.row].name
                navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Delete student?", message: "Are you sure? All of the student's test results will also be deleted.", preferredStyle: .alert)
            
            _ = ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    print("cancelled")
            })
                
            _ = ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let student = self.students[indexPath.row]
        
//                PersistenceService.context.delete(student)
                //Remove the selected student from the table
                self.students.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
//                PersistenceService.saveContext()
                //Find all test events associated with the student
                let request = TestEvent.createFetchRequest()
                let sort = NSSortDescriptor(key: "date", ascending: true)
                request.sortDescriptors = [sort]
                let filter = student.name
                self.testEventPredicate = NSPredicate(format: "student == %@", filter)
                request.predicate = self.testEventPredicate
      
                // check to see if there are testEvents to delete
                if let associatedResults = try? PersistenceService.context.fetch(request) {
                    //If there are go through the array and delete the associated entity instances
                    print("Got \(associatedResults.count) results")
                    for associatedResult in associatedResults {
                        PersistenceService.context.delete(associatedResult)
                    }
                } else {
                    print("No associated results")
                }
//                    previousResultsTableView.reloadData()
                //Now that all their testEvents are gone, we can delete the student
                PersistenceService.context.delete(student)
                //Commit the changes to the database
                PersistenceService.saveContext()

                
                
                
                
            }))
            self.present(ac, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSavedData()
        print("Reloading table data!")
        tableView.reloadData()
    }
    
    
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func done(segue:UIStoryboardSegue) {
        
        print("really done")
        tableView.reloadData()
//        let student = Student(context: PersistenceService.context)
//        student.name = addStudentName
//        // print(student)
//        PersistenceService.saveContext()
//        loadSavedData()
    }
}
