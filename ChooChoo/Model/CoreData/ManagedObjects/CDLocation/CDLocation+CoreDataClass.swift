//
//  Location+CoreDataClass.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 21.11.23.
//
//

import Foundation
import CoreData

@objc(CDLocation)
public class CDLocation: NSManagedObject {
}

extension CDLocation {
	enum ParentEntity {
		case recentLocation(_ user : CDUser)
		case savedLocation(_ user : CDUser)
	}

	convenience init(
		context : NSManagedObjectContext,
		stop : Stop,
		parent : ParentEntity
	){
		self.init(entity: CDLocation.entity(), insertInto: context)

		switch parent {
		case .savedLocation(let user):
			user.addToRecentLocations(self)
		case .recentLocation(let user):
			user.addToRecentLocations(self)
		}
		
		
		self.api_id = stop.stopDTO?.id
		self.address = stop.stopDTO?.address
		self.latitude = stop.coordinates.latitude
		self.longitude = stop.coordinates.longitude
		self.name = stop.name
		self.functionType = stop.type.rawValue
		self.transportType = stop.stopDTO?.products?.lineType?.rawValue
	}
}
