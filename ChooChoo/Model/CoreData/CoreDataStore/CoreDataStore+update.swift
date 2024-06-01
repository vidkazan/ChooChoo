//
//  CoreDataStore.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 07.01.24.
//

import Foundation
import CoreData
import CoreLocation
import OSLog

// MARK: update
extension CoreDataStore {
	func updateJourney(id: Int64,viewData : JourneyViewData,stops : DepartureArrivalPairStop) -> Bool {
		if deleteJourneyIfFound(id: id) {
			return addJourney(id: id,viewData: viewData, stops: stops)
		}
		Logger.coreData.error("\(#function): delete failed")
		return false
	}
	func updateAppSettings(newSettings : AppSettings){
		asyncContext.performAndWait {
			guard let user = self.user else {
				Logger.coreData.error("\(#function): user entity is null")
				return
			}
			guard let settings = try? JSONEncoder().encode(newSettings) else {
				return
			}
			user.appSettings = settings
			self.saveAsyncContext()
		}
	}
	func updateJounreySettings(newSettings : JourneySettings){
		asyncContext.performAndWait {
			guard let user = self.user else {
				Logger.coreData.error("\(#function): user entity is null")
				return
			}
			guard let settings = try? JSONEncoder().encode(newSettings) else {
				Logger.coreData.error("\(#function): settings encoding failed")
				return
			}
			
			user.journeySettings = settings
			self.saveAsyncContext()
		}
	}
	
	func updateRecentSearchTS(search : RecentSearchesViewModel.RecentSearch) -> Bool {
		var result = false
		if let objects = self.fetch(CDRecentSearch.self) {
			 asyncContext.performAndWait {
				if let res = objects.first(where: { obj in
					return obj.id == search.stops.id
				}) {
					res.searchDate = Date(timeIntervalSince1970: search.searchTS)
					self.saveAsyncContext()
					result = true
				}
			}
		}
		return result
	}
}
