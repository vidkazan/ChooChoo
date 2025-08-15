//
//  ApiServiceErrors.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 22.01.24.
//

import Foundation

enum ResponseError : ChewError {
    static func == (lhs: ResponseError, rhs: ResponseError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .internalServerError:
            break
        case .generic:
            break
        case .hafasError(let error):
            hasher.combine(error.hafasCode)
        case .badUrl:
            break
        case .cannotConnectToHost(let string):
            hasher.combine(string)
        case .badServerResponse(let code):
            hasher.combine(code)
        case .cannotDecodeRawData:
            break
        case .cannotDecodeContentData:
            break
        case .badRequest:
            break
        case .requestRateExceeded:
            break
        case .notFound:
            break
        }
    }
    case hafasError(_ hafasError : HafasErrorDTO)
    case internalServerError
    case badUrl
    case cannotConnectToHost(String)
    case badServerResponse(code : Int)
    case cannotDecodeRawData
    case cannotDecodeContentData
    case badRequest
    case requestRateExceeded
    case notFound
    case generic(description : String)
    
    var localizedDescription : String  {
        switch self {
        case .internalServerError:
            return NSLocalizedString(
                "Internal server error",
                comment: "ApiError"
            )
        case .generic(let description):
            return description
        case .hafasError(let error):
            return error.hafasDescription ?? error.hafasMessage ?? error.message ?? NSLocalizedString("Unknown error", comment: "ApiError")
        case .badUrl:
            return NSLocalizedString(
                "Bad url",
                comment: "ApiError"
            )
        case .cannotConnectToHost(let string):
            return string
        case .badServerResponse(let code):
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
        case .stopNotFound:
            return NSLocalizedString(
                "Stop not found",
                comment: "ApiError"
            )
        case .connectionNotFound:
            return NSLocalizedString(
                "Connection not found",
                comment: "ApiError"
            )
        case .failedToGetUserLocation:
            return NSLocalizedString(
                "Failed to get user location",
                comment: "ApiError"
            )
        }
    }
}
