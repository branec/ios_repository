//
//  Picture+CoreDataProperties.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 05.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//
//

import Foundation
import CoreData


extension Picture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Picture> {
        return NSFetchRequest<Picture>(entityName: "Picture")
    }

    @NSManaged public var file_name: String?
    @NSManaged public var name: String?

}
