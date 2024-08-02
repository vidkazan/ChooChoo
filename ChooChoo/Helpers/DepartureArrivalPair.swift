//
//  DepartureArrivalPair.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 27.05.24.
//

import Foundation

struct DepartureArrivalPairStop : Hashable,Codable {
	let departure : Stop
	let arrival : Stop
	let id : String
	init(departure: Stop, arrival: Stop) {
		self.departure = departure
		self.arrival = arrival
		self.id = departure.name + arrival.name
	}
	
	func chooDepartureArrivalPairStop() -> ChooDepartureArrivalPairStop {
		.init(departure: .location(departure), arrival: arrival)
	}
}

struct ChooDepartureArrivalPairStop : Hashable {
	let departure : ChooDeparture
	let arrival : Stop
	let id : String
	init(departure: ChooDeparture, arrival: Stop) {
		self.departure = departure
		self.arrival = arrival
		self.id = departure.stop?.name ?? "departure" + arrival.name
	}
	
	func departureArrivalPairStop() -> DepartureArrivalPairStop? {
		if let dep = departure.stop {
			return .init(
				departure: dep,
			 arrival: arrival
		 )
		}
		return nil
	}
}



struct DepartureArrivalPair<T: Hashable & Codable> : Hashable, Codable {
	let departure : T
	let arrival : T
	init(departure: T, arrival: T) {
		self.departure = departure
		self.arrival = arrival
	}
}

extension DepartureArrivalPair {
	func encode() -> Data? {
		return try? JSONEncoder().encode(self)
	}
	static func decode(data: Data) -> Self? {
		return try? JSONDecoder().decode(Self.self, from: data)
	}
}

