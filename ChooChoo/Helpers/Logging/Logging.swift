//
//  Logging.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 18.04.24.
//

import Foundation
import OSLog
import SwiftUI

struct ChooLogMessage : Codable {
	let category : LoggerCategories
	let subcategory : String
	let msg : String
}

enum LoggerCategories : String,Hashable,CaseIterable, Codable {
	case gitbranch
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
	case view
	case tapButton
	case tapNonTappable
	case journeyDetailsViewModel
}

extension Logger {
	static let locationManager = Logger(category: .locationManager)
	static let mockService = Logger(category: .mockService)
	static let coreData = Logger(category: .coreData)
	static let networking = Logger(category: .networking)
	static let fetchJourneyList = Logger(category: .fetchJourneyList)
	static let fetchJourneyRef = Logger(category: .fetchJourneyRef)
	static let location = Logger(category: .location)
	static let buttonTap = Logger(category: .tapButton)
	static let tapNonTappable = Logger(category: .tapNonTappable)
	static let loadingsInitialData = Logger(category: .loadingsInitialData)
	static let gitBranch = Logger(category: .gitbranch)
	static let journeyDetailsViewModel = Logger(
		category: .journeyDetailsViewModel
	)
	static func create(category : String) -> Logger {
		Logger(
			subsystem: Bundle.main.bundleIdentifier!,
			category: category
		)
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
		Logger(category: .status).trace("\(viewModelName): \(status.description)")
	}
	static func event(
		_ viewModelName : String,
		event : any ChewEvent,
		status : any ChewStatus
	) {
		Logger(category: .event).trace("🔥\(viewModelName): \(event.description) (for state:\(status.description))")
	}
	static func reducer(
		_ viewModelName : String,
		event : any ChewEvent,
		status : any ChewStatus
	) {
		Logger(category: .reducer).warning("\(viewModelName): \(event.description) \(status.description)")
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
