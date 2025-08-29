//
//  PlannedActual.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 05.10.23.
//

import Foundation

struct Prognosed<T: Hashable & Codable> : Hashable,Codable {
    
	var actual : T?
	var planned : T?
	func actualOrPlannedIfActualIsNil() -> T? {
		return actual == nil ? planned : actual
	}
}

extension Prognosed {
	func encode() -> Data? {
		return try? JSONEncoder().encode(self)
	}
	func decode(data: Data) -> Self? {
		return try? JSONDecoder().decode(Self.self, from: data)
	}
}
