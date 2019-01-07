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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "doneSegue" {
//            print("We got here at least")
////            print("Entered name is \(studentNameTextField!.text)")
//
//
//
//
//                addStudentName = "no name entered"
//            }
//
//            //let vc = segue.destination as? ViewController
//            //vc?.addStudentName = addStudentName
//
//        }
//    }
//
    
    @IBAction func donePressed(_ sender: Any) {
        if let testAddStudentName = studentNameTextField?.text  {
            if testAddStudentName != "" {
                let student = Student(context: PersistenceService.context)
                student.name = testAddStudentName
                print(student.name)
                PersistenceService.saveContext()
                _ = navigationController?.popViewController(animated: true)
            } else {
                print("no name entered")
                let ac = UIAlertController(title: "No student name entered.", message: "Please type a student name and then tap the Done button or press Cancel to return to the list of students.", preferredStyle: .alert)
                let _ = ac.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
                    print("cancelled")
                })
                present(ac, animated: true)
                
            }
        }
    }
    
    
    
}
