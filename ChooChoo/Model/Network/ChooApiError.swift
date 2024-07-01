//
//  ChooApiError.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.06.24.
//

import Foundation

enum ChooApiError : ChooError {
	public static func == (lhs: ChooApiError, rhs: ChooApiError) -> Bool {
		return lhs.localizedDescription == rhs.localizedDescription
	}
	
	public func hash(into hasher: inout Hasher) {
		switch self {
		case .hafasError:
			break
		case .generic:
			break
		case .badUrl:
			break
		case .cannotConnectToHost(let string):
			hasher.combine(string)
		case let .badServerResponse(code,_):
			hasher.combine(code)
		case .cannotDecodeRawData:
			break
		case .cannotDecodeContentData:
			break
		case .badRequest:
			break
		case .requestRateExceeded:
			break
		}
	}
	
	case hafasError(_ hafasError : HafasErrorDTO)
	case badUrl
	case cannotConnectToHost(String)
	case badServerResponse(code : Int, body : Data?)
	case cannotDecodeRawData
	case cannotDecodeContentData
	case badRequest
	case requestRateExceeded
	case generic(description : String)
	
	public var localizedDescription : String  {
		switch self {
		case .hafasError(let error):
			return error.hafasDescription ?? error.hafasMessage ?? error.message ?? NSLocalizedString("Error", comment: "DataError")
		case .generic(let description):
			return description
		case .badUrl:
			return NSLocalizedString(
				"Bad url",
				comment: "ApiError"
			)
		case .cannotConnectToHost(let string):
			return string
		case .badServerResponse(let code,_):
			return NSLocalizedString(
				"Bad server response \(code)",
				comment: "ApiError"
			)
		case .cannotDecodeRawData:
			return NSLocalizedString(
				"Server response data nil",
				comment: "ApiError"
			)
		case .cannotDecodeContentData:
			return NSLocalizedString(
				"Server response data decoding",
				comment: "ApiError"
			)
		case .badRequest:
			return NSLocalizedString(
				"Bad search request",
				comment: "ApiError"
			)
		case .requestRateExceeded:
			return NSLocalizedString(
				"Request rate exceeded",
				comment: "ApiError"
			)
		}
	}
}

