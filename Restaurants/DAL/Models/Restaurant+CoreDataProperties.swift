//
//  Restaurant+CoreDataProperties.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 05.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//
//

import Foundation
import CoreData


extension Restaurant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?

}
