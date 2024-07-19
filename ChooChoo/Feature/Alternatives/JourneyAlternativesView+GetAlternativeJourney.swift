//
//  GetAlternativeJourney.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 16.07.24.
//

import Foundation
import Collections

extension JourneyAlternativesView {
	static func getCurrentLegAlternativeJourneyDepartureStop(leg : LegViewData,referenceDate: ChewDate) -> JourneyAlternativeViewData? {
		let now = referenceDate.date
		guard let lastReachableStop = LegViewData.lastReachableStop(stops: leg.legStopsViewData),
			  let lastReachableStopArrivalTime = lastReachableStop.time.date.arrival.actualOrPlannedIfActualIsNil() else {
			return nil
		}
		
		
		let nearestStops = leg.legStopsViewData.filter { stop in
			if let arrival = stop.time.date.arrival.actualOrPlannedIfActualIsNil(),
			   let departure = stop.time.date.departure.actualOrPlannedIfActualIsNil() {
				return departure >= now && now > arrival
			}
			return false
		}
		if
			!nearestStops.isEmpty,
			nearestStops.count == 1,
			let stopViewData = nearestStops.first {
			if 
				let time = stopViewData.time.date.departure.actualOrPlannedIfActualIsNil(),
				time > lastReachableStopArrivalTime {
				return JourneyAlternativeViewData(
					alternativeCase: .currentLegArrivalStopCancelled,
					alternativeDeparture: .stop(stop: lastReachableStop),
					alternativeStopPosition: .onStop
				)
			} else {
				if leg.legType != .line {
					return JourneyAlternativeViewData(
						alternativeCase: .currentLeg,
						alternativeDeparture: .stop(stop: stopViewData),
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
		}
		
		if
			let stopViewData = leg.legStopsViewData.first(where: {
				if let arrival = $0.time.date.arrival.actualOrPlannedIfActualIsNil() {
					return arrival >= now
				}
				return false
			}),
			let time = stopViewData.time.date.arrival.actualOrPlannedIfActualIsNil() {
			
			if time > lastReachableStopArrivalTime {
				return JourneyAlternativeViewData(
					alternativeCase: .currentLegArrivalStopCancelled,
					alternativeDeparture: .stop(stop: lastReachableStop),
					alternativeStopPosition: .onStop
				)
			} else {
				if leg.legType != .line {
					return JourneyAlternativeViewData(
						alternativeCase: .currentLeg,
						alternativeDeparture: .stop(stop: stopViewData),
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
		}
		return nil
	}
	
	static func getAlternativeJourneyDepartureStop(journey : JourneyViewData,referenceDate: ChewDate) -> JourneyAlternativeViewData? {
		let now = referenceDate.date
		
		var legs = journey.legs
		
		if let departureTime = legs.first?.time.date.departure.actualOrPlannedIfActualIsNil(),
		   departureTime > now,
		   let stop  = legs.first?.legStopsViewData.first {
			return JourneyAlternativeViewData(
				alternativeCase: .nowBeforeDeparture,
				alternativeDeparture: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		
		
		let firstNotReachableLeg = legs.first(where: {
			return $0.isReachableFromPreviousLeg == false || $0.legStopsViewData.first?.cancellationType() == .fullyCancelled
		})
		
		legs = legs.filter({
			guard let time = $0.time.timestamp.arrival.actualOrPlannedIfActualIsNil() else {
				return false
			}
			if
			   let firstNotReachableLegTime = firstNotReachableLeg?
				.time
				.timestamp
				.arrival
				.actualOrPlannedIfActualIsNil() {
				return time < firstNotReachableLegTime
			}
			return true
		})
		
		if legs.isEmpty,
		   let stop  = journey.legs.first?.legStopsViewData.first {
			return JourneyAlternativeViewData(
				alternativeCase: .lastReachableLeg,
				alternativeDeparture: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		
		var currentLegs = legs.filter { leg in
			if let arrival = leg.time.date.arrival.actualOrPlannedIfActualIsNil(),
			   let departure = leg.time.date.departure.actualOrPlannedIfActualIsNil() {
				return now > departure && arrival > now
			}
			return false
		}
		
		if currentLegs.count > 1 {
			currentLegs = currentLegs.filter {
				$0.isReachableFromPreviousLeg == false
			}
		}
		
		if !currentLegs.isEmpty,
			currentLegs.count == 1,
			let leg = currentLegs.first {
			return getCurrentLegAlternativeJourneyDepartureStop(leg: leg, referenceDate: referenceDate)
		}
		
		if let stop = LegViewData.lastReachableStop(stops: legs.last?.legStopsViewData ?? []) {
			return .init(
				alternativeCase: .lastReachableLeg,
				alternativeDeparture: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		return nil
	}
}
