//
//  Logging.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 18.04.24.
//

import Foundation
import OSLog

enum LoggerCategories : String,Hashable,CaseIterable {
	case mockService
	case locationManager
	case stateStatus
	case stateEvent
	case reducer
}

extension Logger {
	static let locationManager = Logger(category: .locationManager)
	static let mockService = Logger(category: .mockService)
	static private let stateStatus = Logger(category: .stateStatus)
	static private let stateEvent = Logger(category: .stateEvent)
	static private let reducer = Logger(category: .reducer)
}

extension Logger {
	init(category: LoggerCategories) {
		self.init(
			subsystem: Bundle.main.bundleIdentifier!,
			category: category.rawValue
		)
	}
}

extension Logger {
	static func status(
		_ viewModelName : String,
		status : any ChewStatus
	) {
		Logger.stateStatus.info("\(viewModelName): \(status.description)")
	}
	static func event(
		_ viewModelName : String,
		event : any ChewEvent,
		status : any ChewStatus
	) {
		Logger.stateEvent.info("🔥\(viewModelName): \(event.description) (for state:\(status.description))")
	}
	static func reducer(
		_ viewModelName : String,
		event : any ChewEvent,
		status : any ChewStatus
	) {
		Logger.reducer.warning("\(viewModelName): \(event.description) \(status.description)")
	}
}
