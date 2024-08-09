//
//  ChewDate.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 31.01.24.
//

import Foundation

struct SearchStopsDate : Hashable {
	let date : ChewDate
	let mode : LocationDirectionType
}

enum ChewDate : Equatable,Hashable {
	case now
	case specificDate(_ ts : Double)
	
	var date : Date {
		switch self {
		case .now:
			return .now
		case .specificDate(let ts):
			return Date(timeIntervalSince1970: ts)
		}
	}
	var ts : Double {
		switch self {
		case .now:
			return Date.now.timeIntervalSince1970
		case .specificDate(let ts):
			return ts
		}
	}
}
