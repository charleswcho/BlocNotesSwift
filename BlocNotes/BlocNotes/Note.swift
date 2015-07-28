//
//  Note.swift
//  BlocNotes
//
//  Created by Charles Wesley Cho on 7/28/15.
//  Copyright (c) 2015 Charles Wesley Cho. All rights reserved.
//

import Foundation
import CoreData

//@objc(Note)
class Note: NSManagedObject {

    @NSManaged var noteText: String
    @NSManaged var noteTitle: String
    @NSManaged var timeStamp: NSDate

}
