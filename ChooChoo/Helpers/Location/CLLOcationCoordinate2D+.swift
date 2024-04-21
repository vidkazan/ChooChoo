//
//  CLLOcationCoordinate2D+hash.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 12.09.23.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Hashable,Equatable{
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
}


extension CLLocationCoordinate2D: Identifiable {
	public var id: String {
		"\(latitude)-\(longitude)"
	}
}

extension CLLocation {
	func distance(_ from : CLLocationCoordinate2D) -> CLLocationDistance {
		return self.distance(from: CLLocation(latitude: from.latitude, longitude: from.longitude))
	}
}

extension CLLocation {
	func getRadiansFrom(degrees: Double ) -> Double {
		return degrees * .pi / 180
	}

	func getDegreesFrom(radians: Double) -> Double {
		return radians * 180 / .pi
	}


	func bearingRadianTo(location: CLLocation) -> Double {

		let lat1 = self.getRadiansFrom(degrees: self.coordinate.latitude)
		let lon1 = self.getRadiansFrom(degrees: self.coordinate.longitude)

		let lat2 = self.getRadiansFrom(degrees: location.coordinate.latitude)
		let lon2 = self.getRadiansFrom(degrees: location.coordinate.longitude)

		let dLon = lon2 - lon1

		let y = sin(dLon) * cos(lat2)
		let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

		var radiansBearing = atan2(y, x)

		if radiansBearing < 0.0 {
			radiansBearing += 2 * .pi
		}


		return radiansBearing
	}

	func bearingDegreesTo(location: CLLocation) -> Double {
		return self.getDegreesFrom(radians: self.bearingRadianTo(location: location))
	}
}
