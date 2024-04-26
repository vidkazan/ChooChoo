//
//  Logging.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 18.04.24.
//

import Foundation
import OSLog
import SwiftUI

enum LoggerCategories : String,Hashable,CaseIterable {
	case mockService
	case locationManager
	case status
	case event
	case reducer
	case coreData
	case networking
	case fetchJourneyList
	case fetchJourneyRef
	case loadingsInitialData
	case location
	case journeyDetailsViewModel
}

extension Logger {
	static let locationManager = Logger(category: .locationManager)
	static let mockService = Logger(category: .mockService)
	static let coreData = Logger(category: .coreData)
	static let networking = Logger(category: .networking)
	static private let status = Logger(category: .status)
	static private let event = Logger(category: .event)
	static private let reducer = Logger(category: .reducer)
	static let fetchJourneyList = Logger(category: .fetchJourneyList)
	static let fetchJourneyRef = Logger(category: .fetchJourneyRef)
	static let location = Logger(category: .location)
	static let loadingsInitialData = Logger(category: .loadingsInitialData)
	static let journeyDetailsViewModel = Logger(category: .journeyDetailsViewModel)
	static func create(category : String) -> Logger {
		Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
	}
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
		Logger.status.trace("\(viewModelName): \(status.description)")
	}
	static func event(
		_ viewModelName : String,
		event : any ChewEvent,
		status : any ChewStatus
	) {
		Logger.event.trace("🔥\(viewModelName): \(event.description) (for state:\(status.description))")
	}
	static func reducer(
		_ viewModelName : String,
		event : any ChewEvent,
		status : any ChewStatus
	) {
		Logger.reducer.warning("\(viewModelName): \(event.description) \(status.description)")
	}
}

extension OSLogEntryLog {
	var color: Color {
		switch level {
		case .info:
			return .blue
		case .debug:
			return .gray
		case .notice:
			return .yellow
		case .error, .fault: 
			return .red
		default:
			return .gray
		}
	}
}
