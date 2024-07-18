//
//  GetAlternativeJourney.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 16.07.24.
//

import Foundation

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
		
		let lastReachableLeg = legs.last(where: {
			$0.delayedAndNextIsNotReachable == nil && $0.time.departureStatus != .cancelled
		})
		
		print(
			lastReachableLeg!.lineViewData.name,
			lastReachableLeg!.legStopsViewData.first!.name,
			lastReachableLeg!.legStopsViewData.last!.name
		)
		
		legs = legs.filter({
			$0.time.timestamp.arrival.planned ?? 1 <= lastReachableLeg?.time.timestamp.arrival.planned ?? 0
		})
		
		var currentLegs = legs.filter { leg in
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
		
		if let stop = LegViewData.lastReachableStop(stops: lastReachableLeg?.legStopsViewData ?? []) {
			return .init(
				alternativeCase: .lastReachableLeg,
				alternativeDeparture: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		return nil
	}
}
