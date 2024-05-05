//
//  SearchHistory+CoreDataProperties.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/14/24.
//
//

import Foundation
import CoreData


extension SearchHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistory> {
        return NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
    }

    @NSManaged public var city: String?
    @NSManaged public var id: UUID?
    @NSManaged public var source: String?
    @NSManaged public var type: String?
    @NSManaged public var newsTitle: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var newsSource: String?
    @NSManaged public var newsAuthor: String?
    @NSManaged public var dateTime: Date?
    @NSManaged public var temprature: String?
    @NSManaged public var humidity: String?
    @NSManaged public var wind: String?
    @NSManaged public var startPoint: String?
    @NSManaged public var endPoint: String?
    @NSManaged public var methodOfTravel: String?
    @NSManaged public var distanceTravelled: String?

}

extension SearchHistory : Identifiable {

}
