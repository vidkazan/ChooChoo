//
//  GetAlternativeJourney.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 16.07.24.
//

import Foundation

extension JourneyAlternativesView {
	func getCurrentLegAlternativeJourneyDepartureStop(leg : LegViewData,referenceDate: ChewDate) -> JourneyAlternativeViewData? {
		let now = referenceDate.date
		guard let lastReachableStop = LegViewData.lastAvailableStop(stops: leg.legStopsViewData),
			  let lastDepartureStopArrivalTime = lastReachableStop.time.date.arrival.actualOrPlannedIfActualIsNil() else {
			return nil
		}
		
		
		let nearestStops = leg.legStopsViewData.filter { stop in
			if let arrival = stop.time.date.arrival.actualOrPlannedIfActualIsNil(),
			   let departure = stop.time.date.departure.actualOrPlannedIfActualIsNil() {
				return now > arrival && departure > now
			}
			return false
		}
		if
			!nearestStops.isEmpty,
			nearestStops.count == 1,
			let stopViewData = nearestStops.first {
			if let time = stopViewData.time.date.departure.actualOrPlannedIfActualIsNil(), time > lastDepartureStopArrivalTime {
				return JourneyAlternativeViewData(
					alternativeCase: .currentLegArrivalStopCancelled,
					alternativeDeparture: .stop(stop: lastReachableStop),
					alternativeStopPosition: .onStop
				)
			} else {
				return JourneyAlternativeViewData(
					alternativeCase: .currentLeg,
					alternativeDeparture: .onTransport(nearestStop: stopViewData, leg: leg),
					alternativeStopPosition: .onStop
				)
			}
		}
		
		if
			let stopViewData = leg.legStopsViewData.first(where: {
				if let arrival = $0.time.date.arrival.actualOrPlannedIfActualIsNil() {
					return arrival > now
				}
				return false
			}),
			let time = stopViewData.time.date.arrival.actualOrPlannedIfActualIsNil() {
			
			if time > lastDepartureStopArrivalTime {
				return JourneyAlternativeViewData(
					alternativeCase: .currentLegArrivalStopCancelled,
					alternativeDeparture: .stop(stop: lastReachableStop),
					alternativeStopPosition: .onStop
				)
			} else {
				return JourneyAlternativeViewData(
					alternativeCase: .currentLeg,
					alternativeDeparture: .onTransport(nearestStop: stopViewData, leg: leg),
					alternativeStopPosition: .headingToStop(time: time)
				)
			}
		}
		return nil
	}
	
	func getAlternativeJourneyDepartureStop(journey : JourneyViewData,referenceDate: ChewDate) -> JourneyAlternativeViewData? {
		let now = referenceDate.date
		
		if let departureTime = journey.time.date.departure.actualOrPlannedIfActualIsNil(),
		   departureTime > now,
		   let stop  = journey.legs.first?.legStopsViewData.first {
			return JourneyAlternativeViewData(
				alternativeCase: .nowBeforeDeparture,
				alternativeDeparture: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		
		let lastReachableLeg = journey.legs.last(where: {
			$0.delayedAndNextIsNotReachable != true &&
			$0.direction.actualOrPlannedIfActualIsNil() != nil
		})
		
		var currentLegs = journey.legs.filter { leg in
			if let arrival = leg.time.date.arrival.actualOrPlannedIfActualIsNil(),
			   let departure = leg.time.date.departure.actualOrPlannedIfActualIsNil() {
				return now > departure && arrival > now
			}
			return false
		}
		
		if currentLegs.count > 1 {
			currentLegs = currentLegs.filter {
				$0.isReachable == false
			}
		} else {
			if let leg = currentLegs.first {
				if leg.direction.actualOrPlannedIfActualIsNil() == nil {
					currentLegs = []
				}
			}
		}
		
		if !currentLegs.isEmpty,
			currentLegs.count == 1,
			let leg = currentLegs.first {
			return getCurrentLegAlternativeJourneyDepartureStop(leg: leg, referenceDate: referenceDate)
		}
		
		if let stop  = lastReachableLeg?.direction.actualOrPlannedIfActualIsNil() {
			return .init(
				alternativeCase: .lastReachableLeg,
				alternativeDeparture: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		return nil
	}
}
