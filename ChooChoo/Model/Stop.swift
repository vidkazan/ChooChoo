//
//  Location.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 13.10.23.
//

import Foundation
import CoreLocation

struct Stop : Identifiable,Hashable,Codable {
	let id : String
	var coordinates: Coordinate
	var type: LocationType
	var stopDTO : StopDTO?
	var name : String
	
	init(coordinates: Coordinate, type: LocationType, stopDTO: StopDTO?) {
		self.coordinates = coordinates
		self.type = type
		self.stopDTO = stopDTO
		self.name = stopDTO?.name ?? stopDTO?.address ?? "\(String(coordinates.latitude).prefix(6)) , \(String(coordinates.longitude).prefix(6))"
		self.id = stopDTO?.id ?? self.name
	}
}

extension Stop {
	func stopAnnotation(stopOverType : StopOverType?) -> StopAnnotation? {
		if let products = stopDTO?.products {
			let type = products.lineType
			if let type = type {
				return StopAnnotation(
					stopId: id,
					name: name,
					location: coordinates.cllocationcoordinates2d,
					type: type,
					stopOverType: stopOverType
				)
			}
		}
		return nil
	}
}

struct StopWithDistance : Hashable {
	func hash(into hasher: inout Hasher) {
			hasher.combine(stop)
		}
	let stop : Stop
	let distance : Double?
}
