//
//  CLLOcationCoordinate2D+hash.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 12.09.23.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Hashable, Identifiable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
	public var id: String {
		"\(latitude)-\(longitude)"
	}
}
