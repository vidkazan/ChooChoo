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
}

extension Logger {
	private static var subsystem = Bundle.main.bundleIdentifier!

	/// Logs the view cycles like a view that appeared.
	static let locationManager = Logger(category: .locationManager)
	static let mockService = Logger(category: .mockService)

}

extension Logger {
	init(category: LoggerCategories) {
		self.init(subsystem: Bundle.main.bundleIdentifier!, category: category.rawValue)
	}
}
