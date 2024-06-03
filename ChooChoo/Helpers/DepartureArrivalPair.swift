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

