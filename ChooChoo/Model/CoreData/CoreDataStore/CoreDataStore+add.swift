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
import FcodyCoreData

// MARK: add
extension ChooDataStore {
	func addRecentLocation(stop : Stop){
		guard let user = self.user else { return }
		 asyncContext.performAndWait {
			 if stop.stopDTO?.products != nil {
				 let _ = CDLocation(
					context: self.asyncContext,
					stop: stop,
					parent: .recentLocation(user)
				 )
				 self.saveAsyncContext()
			 }
		}
	}
	
	func addJourney(
		id : Int64,
		viewData : JourneyViewData,
		stops : DepartureArrivalPairStop
	) -> Bool {
		var res = false
		guard let user = self.user else {
			Logger.coreData.error("\(#function): user is nil")
			return false
		}
		asyncContext.performAndWait {
			let _ = CDJourney(
				viewData: viewData,
				user: user,
				stops: stops,
				id: id,
				using: self.asyncContext
			)
			self.saveAsyncContext()
			res = true
		}
		return res
	}
	
	func addRecentSearch(search : RecentSearchesViewModel.RecentSearch) -> Bool {
		var res = false
		guard let user = self.user else {
			Logger.coreData.error("\(#function): user is nil")
			return false
		}
		 asyncContext.performAndWait {
			let _ = CDRecentSearch(
				user: user,
				search: search,
				using: self.asyncContext
			)
			self.saveAsyncContext()
			res = true
		}
		return res
	}
}
