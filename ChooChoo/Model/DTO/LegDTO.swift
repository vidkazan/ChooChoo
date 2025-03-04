//
//  LegDTO.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 18.07.24.
//

import Foundation
import SwiftUI
import CoreLocation

struct TripDTO : Identifiable, ChewDTO {
	let id = UUID()
	let trip : LegDTO
	private enum CodingKeys : String, CodingKey {
		case trip
	}
}

struct LegDTO : Identifiable, ChewDTO {
//	let id = UUID()
	var id : Int { hashValue }
	let origin : StopDTO?
	let destination : StopDTO?
	let line : LineDTO?
	let remarks : [Remark]?
	let departure: String?
	let plannedDeparture: String?
	let arrival: String?
	let plannedArrival: String?
	let departureDelay,
		arrivalDelay: Int?
	let tripId : String?
	let tripIdAlternative : String?
	let direction: String?
	let currentLocation: Coordinate?
	let arrivalPlatform,
		plannedArrivalPlatform: String?
	let departurePlatform,
		plannedDeparturePlatform : String?
	let walking : Bool?
	let distance : Int?
	let stopovers : [StopWithTimeDTO]?
	let polyline : PolylineDTO?
	
	private enum CodingKeys : String, CodingKey {
		case origin
		case destination
		case line
		case remarks
		case departure
		case plannedDeparture
		case arrival
		case plannedArrival
		case departureDelay
		case arrivalDelay
		case tripId = "tripId"
		case tripIdAlternative = "id"
		case direction
		case currentLocation
		case arrivalPlatform
		case plannedArrivalPlatform
		case departurePlatform
		case plannedDeparturePlatform
		case walking
		case stopovers
		case distance
		case polyline
	}
}

extension LegDTO {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.origin = try container.decodeIfPresent(StopDTO.self, forKey: .origin)
        self.destination = try container.decodeIfPresent(StopDTO.self, forKey: .destination)
        self.line = try container.decodeIfPresent(LineDTO.self, forKey: .line)
        self.remarks = try container.decodeIfPresent([Remark].self, forKey: .remarks)
        self.departure = try container.decodeIfPresent(String.self, forKey: .departure)
        self.plannedDeparture = try container.decodeIfPresent(String.self, forKey: .plannedDeparture)
        self.arrival = try container.decodeIfPresent(String.self, forKey: .arrival)
        self.plannedArrival = try container.decodeIfPresent(String.self, forKey: .plannedArrival)
        self.departureDelay = try container.decodeIfPresent(Int.self, forKey: .departureDelay)
        self.arrivalDelay = try container.decodeIfPresent(Int.self, forKey: .arrivalDelay)
        self.tripIdAlternative = try container.decodeIfPresent(String.self, forKey: .tripIdAlternative)
        if self.tripIdAlternative == nil {
            self.tripId = try container.decodeIfPresent(String.self, forKey: .tripId)
        } else {
            self.tripId = self.tripIdAlternative
        }
        self.direction = try container.decodeIfPresent(String.self, forKey: .direction)
        self.currentLocation = try container.decodeIfPresent(Coordinate.self, forKey: .currentLocation)
        self.arrivalPlatform = try container.decodeIfPresent(String.self, forKey: .arrivalPlatform)
        self.plannedArrivalPlatform = try container.decodeIfPresent(String.self, forKey: .plannedArrivalPlatform)
        self.departurePlatform = try container.decodeIfPresent(String.self, forKey: .departurePlatform)
        self.plannedDeparturePlatform = try container.decodeIfPresent(String.self, forKey: .plannedDeparturePlatform)
        self.walking = try container.decodeIfPresent(Bool.self, forKey: .walking)
        self.stopovers = try container.decodeIfPresent([StopWithTimeDTO].self, forKey: .stopovers)
        self.distance = try container.decodeIfPresent(Int.self, forKey: .distance)
        self.polyline = try container.decodeIfPresent(PolylineDTO.self, forKey: .polyline)
    }
}
