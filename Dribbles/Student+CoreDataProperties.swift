//
//  Student+CoreDataProperties.swift
//  Dribbles
//
//  Created by Alistair Logie on 12/22/18.
//  Copyright © 2018 Alistair Logie. All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String
    @NSManaged public var testEvents: NSSet?

}

// MARK: Generated accessors for testEvents
extension Student {

    @objc(addTestEventsObject:)
    @NSManaged public func addToTestEvents(_ value: TestEvent)

    @objc(removeTestEventsObject:)
    @NSManaged public func removeFromTestEvents(_ value: TestEvent)

    @objc(addTestEvents:)
    @NSManaged public func addToTestEvents(_ values: NSSet)

    @objc(removeTestEvents:)
    @NSManaged public func removeFromTestEvents(_ values: NSSet)

}
