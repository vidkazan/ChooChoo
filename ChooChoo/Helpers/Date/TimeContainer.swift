//
//  TimeContainer.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 29.09.23.
//

import Foundation

// MARK: TimeContainer
struct TimeContainer : Hashable, Codable {
	enum DelayStatus : Hashable, Codable  {
		case onTime
		case delay(Int)
		case cancelled
		
		var value : Int? {
			switch self {
			case .cancelled:
				return nil
			case .delay(let time):
				return time
			case .onTime:
				return 0
			}
		}
		
		var description : String {
			switch self {
			case .cancelled:
				return "cancelled"
			case .delay(let time):
				return "delay \(time.description)"
			case .onTime:
				return "onTime"
			}
		}
	}
	
	let iso : ISOTimeContainer
	let date : DateTimeContainer
	let timestamp : TimestampTimeContainer
	let departureStatus : DelayStatus
	let arrivalStatus : DelayStatus
	let durationInMinutes : Int
}

extension TimeContainer {
	// MARK: Init
	init(iso : ISOTimeContainer) {
		self.init(
			plannedDeparture: iso.departure.planned,
			plannedArrival: iso.arrival.planned,
			actualDeparture: iso.departure.actual,
			actualArrival: iso.arrival.actual,
			cancelled: nil
		)
	}
	init() {
		let departure = Prognosed<String>(
			actual: nil,
			planned: nil
		)
		let arrival = Prognosed<String>(
			actual: nil,
			planned: nil
		)
		self.iso = ISOTimeContainer(departure: departure,arrival: arrival)
		self.date = self.iso.getDateContainer()
		self.timestamp = self.date.getTSContainer()
		self.departureStatus = self.timestamp.generateDelayStatus(type: .departure, cancelled: false)
		self.arrivalStatus = self.timestamp.generateDelayStatus(type: .arrival, cancelled: false)
		self.durationInMinutes = -1
	}
	
	init(
		plannedDeparture: String?,
		plannedArrival: String?,
		actualDeparture: String?,
		actualArrival: String?,
		cancelled : Bool?
	) {
		let departure = Prognosed(
			actual: actualDeparture,
			planned: plannedDeparture
		)
		let arrival = Prognosed(
			actual: actualArrival,
			planned: plannedArrival
		)
		self.iso = ISOTimeContainer(departure: departure,arrival: arrival)
		self.date = self.iso.getDateContainer()
		self.timestamp = self.date.getTSContainer()
		self.departureStatus = self.timestamp.generateDelayStatus(type: .departure, cancelled: cancelled)
		self.arrivalStatus = self.timestamp.generateDelayStatus(type: .arrival, cancelled:  cancelled)
		self.durationInMinutes = DateParcer.getTwoDateIntervalInMinutes(
			date1: self.date.departure.actualOrPlannedIfActualIsNil(),
			date2: self.date.arrival.actualOrPlannedIfActualIsNil()
		) ?? -1
	}
}


extension TimeContainer {
	// MARK: ISO Container
	struct ISOTimeContainer : Hashable, Codable {
		let departure : Prognosed<String>
		let arrival : Prognosed<String>
		
		func getDateContainer() -> DateTimeContainer {
			return DateTimeContainer(
				departure: Prognosed(
					actual: DateParcer.getDateFromDateString(dateString: departure.actual),
					planned: DateParcer.getDateFromDateString(dateString: departure.planned)
				),
				arrival: Prognosed(
					actual: DateParcer.getDateFromDateString(dateString: arrival.actual),
					planned: DateParcer.getDateFromDateString(dateString: arrival.planned)
				)
			)
		}
	}
	// MARK: Date Container
	struct DateTimeContainer : Hashable, Codable  {
		let departure : Prognosed<Date>
		let arrival : Prognosed<Date>
		
		func getTSContainer() -> TimestampTimeContainer {
			return TimestampTimeContainer(
				departure: Prognosed(
					actual: departure.actual?.timeIntervalSince1970,
					planned: departure.planned?.timeIntervalSince1970
				),
				arrival: Prognosed(
					actual: arrival.actual?.timeIntervalSince1970,
					planned: arrival.planned?.timeIntervalSince1970
				)
			)
		}
	}
	
	// MARK: TS Container
	struct TimestampTimeContainer : Hashable, Codable  {
		let departure : Prognosed<Double>
		let arrival : Prognosed<Double>
		
		func generateDelayStatus(type: LocationDirectionType, cancelled : Bool?) -> DelayStatus {
			let time : Prognosed<Double> = {
				switch type {
				case .departure:
					return self.departure
				case .arrival:
					return self.arrival
				}
			}()
			
			if time.actual == nil {
				return .cancelled
			}
			
			let delay = Int((time.actual ?? 0) - (time.planned ?? 0)) / 60
			if delay >= 1 {
				return .delay(delay)
			} else {
				return .onTime
			}
		}
	}
	
	func getStopCurrentTimePositionAlongActualDepartureAndArrival(currentTS: Double?) -> Double? {
		let fTs : Double = self.timestamp.arrival.actual ?? self.timestamp.departure.actual ?? 0
		let lTs : Double = self.timestamp.departure.actual ?? self.timestamp.arrival.actual ?? 0
		guard let cTs = currentTS else { return nil }
		
		let res = (cTs - fTs) / (lTs - fTs)
		
		return res > 0 ? (res > 1 ? 1 : res) : 0
	}
}

extension TimeContainer {
	enum Status : String,Hashable,CaseIterable {
		case ongoingFar
		case ongoing
		case ongoingSoon
		case active
		case past
		
		var updateIntervalInMinutes : Double {
			switch self{
			case .active:
				return 1
			case .ongoingSoon:
				return 5
			case .ongoing:
				return 30
			case .ongoingFar:
				return 240
			case .past:
				return 10000000
			}
		}
	}
	
	func statusOnReferenceTime(_ referenceTime : ChewDate) -> Status {
		let departureTS = (self.timestamp.departure.actualOrPlannedIfActualIsNil() ?? .greatestFiniteMagnitude)
		let arrivalTS = (self.timestamp.arrival.actualOrPlannedIfActualIsNil() ?? .greatestFiniteMagnitude)
		
		let day = departureTS - 24 * 60 * 60
		let hour = departureTS - 1 * 60 * 60
		switch referenceTime.ts {
		case 0...day:
			return .ongoingFar
		case day...hour:
			return .ongoing
		case hour...(departureTS-60):
			return .ongoingSoon
		case (departureTS-60)...(arrivalTS+60):
			return .active
		default:
			return .past
		}
	}
}

extension TimeContainer {
	func encode() -> Data? {
		return try? JSONEncoder().encode(self.iso)
	}
	
	init?(isoEncoded : Data) {
		if let iso = try? JSONDecoder().decode(ISOTimeContainer.self, from: isoEncoded) {
			self.init(iso: iso)
		} else {
			return nil
		}
	}
}
