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
