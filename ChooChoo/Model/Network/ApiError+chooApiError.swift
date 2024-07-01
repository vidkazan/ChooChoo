//
//  ChooApiError.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.06.24.
//

import Foundation
import ChooNetworking

extension ApiError {
	func chooApiError() -> ChooApiError {
		switch self {
		case .badUrl:
			return .badUrl
		case .cannotConnectToHost(let string):
			return .cannotConnectToHost(string)
		case .badServerResponse(let code, let body):
			if let body = body, let data = try? JSONDecoder().decode(HafasErrorDTO.self, from: body) {
				return .hafasError(data)
			}
			return .badServerResponse(code: code, body: nil)
		case .cannotDecodeRawData:
			return .cannotDecodeRawData
		case .cannotDecodeContentData:
			return .badUrl
		case .badRequest:
			return .badRequest
		case .requestRateExceeded:
			return .requestRateExceeded
		case .generic(let description):
			return .generic(description: description)
		}
	}
}
