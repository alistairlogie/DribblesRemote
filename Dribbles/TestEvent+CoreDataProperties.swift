//
//  TestEvent+CoreDataProperties.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/22/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//
//

import Foundation
import CoreData


extension TestEvent {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<TestEvent> {
        return NSFetchRequest<TestEvent>(entityName: "TestEvent")
    }

    @NSManaged public var date: NSDate
    @NSManaged public var score: Float
    @NSManaged public var student: String?
    @NSManaged public var testType: String?
    @NSManaged public var students: Student?

}
