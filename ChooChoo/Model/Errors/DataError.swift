//
//  DataError.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.06.24.
//

import Foundation

enum DataError : ChooError {
	static func == (lhs: DataError, rhs: DataError) -> Bool {
		return lhs.localizedDescription == rhs.localizedDescription
	}
	
	func hash(into hasher: inout Hasher) {
		switch self {
		case .generic,.nilValue,.validationError,.connectionNotFound,.failedToGetUserLocation, .stopNotFound:
			break
		}
	}
	case stopNotFound
	case connectionNotFound
	case failedToGetUserLocation
	case validationError(msg: String)
	case nilValue(type : String)
	case generic(msg: String)
	
	var localizedDescription : String  {
		switch self {
		case .validationError(let msg):
			return NSLocalizedString("validation error: \(msg)", comment: "DataError")
		case .nilValue(type: let type):
			return NSLocalizedString("nil error: \(type)", comment: "DataError")
		case .generic(let msg):
			return NSLocalizedString("error: \(msg)", comment: "DataError")
		case .stopNotFound:
			return NSLocalizedString(
				"Stop not found",
				comment: "DataError"
			)
		case .connectionNotFound:
			return NSLocalizedString(
				"Connection not found",
				comment: "DataError"
			)
		case .failedToGetUserLocation:
			return NSLocalizedString(
				"Failed to get user location",
				comment: "DataError"
			)
		}
	}
}
