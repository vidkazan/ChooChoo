//
//  ApiServiceErrors.swift.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation

protocol ChewError : Error, Hashable {
//    var description : String { get }
    var localizedDescription : String { get }
}

enum DataError : ChewError {
    static func == (lhs: DataError, rhs: DataError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .generic,.nilValue,.validationError:
            break
        }
    }
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
        }
    }
}

