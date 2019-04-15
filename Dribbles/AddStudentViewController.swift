//
//  AddStudentViewController.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/14/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//

import UIKit

class AddStudentViewController: UIViewController {
    
    var addStudentName:String = ""
    
    @IBOutlet weak var studentNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func donePressed(_ sender: Any) {
        if let testAddStudentName = studentNameTextField?.text  {
            if testAddStudentName != "" {
                let student = Student(context: PersistenceService.context)
                student.name = testAddStudentName
                PersistenceService.saveContext()
                _ = navigationController?.popViewController(animated: true)
            } else {
                let ac = UIAlertController(title: "No student name entered.", message: "Please type a student name and then tap the Done button or press Cancel to return to the list of students.", preferredStyle: .alert)
                let _ = ac.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
                })
                present(ac, animated: true)
                
            }
        }
    }
    
    
    
}
