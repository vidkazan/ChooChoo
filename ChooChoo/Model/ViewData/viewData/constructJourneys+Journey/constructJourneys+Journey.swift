//
//  ConstructJourneyData+Journey.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//
import Foundation
import CoreLocation
import SwiftUI

extension JourneyDTO {
	func journeyViewDataAsync(
		depStop: Stop?,
		arrStop : Stop?,
		realtimeDataUpdatedAt: Double,
		settings : JourneySettings
	) async -> JourneyViewData? {
		return journeyViewData(
			depStop: depStop,
			arrStop: arrStop,
			realtimeDataUpdatedAt: realtimeDataUpdatedAt,
			settings: settings
		)
	}

	func journeyViewData(
		depStop: Stop?,
		arrStop : Stop?,
		realtimeDataUpdatedAt: Double,
		settings : JourneySettings
	) -> JourneyViewData? {
		do {
			return try journeyViewDataThrows(
				depStop: depStop,
				arrStop: arrStop,
				realtimeDataUpdatedAt: realtimeDataUpdatedAt,
				settings: settings
			)
		} catch  {
			return nil
		}
	}


	func journeyViewDataThrows(
		depStop: Stop?,
		arrStop : Stop?,
		realtimeDataUpdatedAt: Double,
		settings : JourneySettings
	) throws -> JourneyViewData {
		let time = TimeContainer(
			plannedDeparture: legs.first?.plannedDeparture,
			plannedArrival: legs.last?.plannedArrival,
			actualDeparture: legs.first?.departure,
			actualArrival: legs.last?.arrival,
			cancelled: nil
		)
		var isReachable = true
		var legsData : [LegViewData] = []
		let startTS = max(time.date.departure.actual ?? .distantPast, time.date.departure.planned ?? .distantPast)
		let endTS = max(time.date.arrival.planned ?? .distantPast,time.date.arrival.actual ?? .distantPast)
		let legs = legs
		let journeyRemarks = remarks?.compactMap({$0.viewData()}) ?? []
		var legRemarks = [RemarkViewData]()
		
		
		legs.forEach({ leg in
			legRemarks += leg.remarks?.compactMap({$0.viewData()}) ?? []
			isReachable = true
			if var currentLeg = leg.legViewData(firstTS: startTS, lastTS: endTS, legs: legs) {
				if let last = legsData.last {
					if currentLegIsNotReachable(
						currentLeg: currentLeg,
						previousLeg: last
					) == true {
						legsData[legsData.count-1].delayedAndNextIsNotReachable = true
						isReachable = false
						currentLeg.isReachableFromPreviousLeg = false
					}
					if case .line = currentLeg.legType, case .line = last.legType {
						if let transfer = constructTransferViewData(fromLeg: last, toLeg: currentLeg) {
							legsData.append(transfer)
						}
					}
				}
				legsData.append(currentLeg)
			}
		})
		let sunEventService = SunEventService(
			locationStart: depStop?.coordinates ?? .init(),
			locationFinal: arrStop?.coordinates ?? .init(),
			dateStart: startTS,
			dateFinal: endTS
		)
		
		guard let journeyRef = refreshToken else  {
			throw DataError.nilValue(type: "journeyRef")
		}
		guard let first = legs.first?.origin,
			  let last = legs.last?.destination else  {
			throw DataError.nilValue(type: "first or last stop")
		}
		guard let dep = time.timestamp.departure.actualOrPlannedIfActualIsNil(),
			  let arr = time.timestamp.arrival.actualOrPlannedIfActualIsNil(),
			  arr > dep else {
			throw DataError.validationError(msg: "arrivalTime < departureTime")
		}
		
		return JourneyViewData(
			journeyRef: journeyRef,
			badges: constructBadges(remarks: legRemarks,isReachable: isReachable),
			sunEvents: sunEventService.getSunEvents(),
			legs: legsData,
			depStopName: legs.first?.origin?.name ?? first.address,
			arrStopName: legs.last?.destination?.name ?? last.address,
			time: time,
			updatedAt: realtimeDataUpdatedAt,
			remarks: journeyRemarks,
			settings: settings,
			journeyDTO: self
		)
	}
}


func getGradientStops(startDateTS : Double?, endDateTS : Double?,sunEvents : [SunEvent] ) -> [Gradient.Stop] {
	let nightColor = Color.chewSunEventBlue
	let dayColor = Color.chewSunEventYellow
	var stops : [Gradient.Stop] = []
	for event in sunEvents {
		if
			let startDateTS = startDateTS,
			let endDateTS = endDateTS {
			switch event.type {
			case .sunrise:
				stops.append(Gradient.Stop(
					color: nightColor,
					location: (event.timeStart.timeIntervalSince1970 - startDateTS) / (endDateTS - startDateTS)
				))
				if let final = event.timeFinal {
					stops.append(Gradient.Stop(
						color: dayColor,
						location: (final.timeIntervalSince1970 - startDateTS) / (endDateTS - startDateTS)
					))
				}
			case .day:
				stops.append(Gradient.Stop(
					color: dayColor,
					location: 0
				))
			case .sunset:
				stops.append(Gradient.Stop(
					color: dayColor,
					location: (event.timeStart.timeIntervalSince1970 - startDateTS) / (endDateTS - startDateTS)
				))
				if let final = event.timeFinal {
					stops.append(Gradient.Stop(
						color: nightColor,
						location:  (final.timeIntervalSince1970 - startDateTS) / (endDateTS - startDateTS)
					))
				}
			case .night:
				stops.append(Gradient.Stop(
					color: nightColor,
					location: 0
				))
			}
		}
	}
	return stops.sorted(by: {$0.location < $1.location})
}
