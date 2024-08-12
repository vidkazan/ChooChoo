//
//  CDJourney+CoreDataClass.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 21.11.23.
//
//

import Foundation
import CoreData

@objc(CDJourney)
public class CDJourney: NSManagedObject {

}

extension CDJourney {
	func journeyFollowData() -> JourneyFollowData? {
		var legsViewData = [LegViewData]()
		var sunEvents = [SunEvent]()
		var data : JourneyFollowData? = nil
		self.managedObjectContext?.performAndWait {
			legsViewData = legs.compactMap {
				$0.legViewData()
			}
			
			if 
				let sunEventsData = self.sunEvents,
				let sun = try? JSONDecoder().decode(Set<SunEvent>.self, from: sunEventsData) {
				sunEvents = Array(sun)
			}
			guard let stops = try? JSONDecoder().decode(
				DepartureArrivalPairStop.self, 
				from: self.depArrStops
			) else {
				return
			}
			
			guard let settData = self.journeySettings,
				let settings = try? JSONDecoder().decode(
				JourneySettings.self,
				from: settData
			) else {
				return
			}
			guard let time = TimeContainer(isoEncoded: self.time) else {
				return
			}
			
			let jvd = JourneyViewData(
				journeyRef: journeyRef,
				   badges: [],
				   sunEvents: sunEvents,
				   legs: legsViewData,
				   depStopName: stops.departure.name,
				   arrStopName: stops.arrival.name,
				   time: time,
				   updatedAt: self.updatedAt,
				   remarks: [],
				   settings: settings,
				   journeyDTO: nil
			   )
			let actions = jvd.journeyActions()
//			#warning("add remarks")
			data = JourneyFollowData(
				id : self.id,
				journeyViewData: jvd,
				stops: stops,
				journeyActions: actions
			)
		}
		return data
	}
}
