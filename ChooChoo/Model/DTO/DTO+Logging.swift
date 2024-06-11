//
//  DTO+Logging.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 11.06.24.
//

import Foundation
import OSLog


protocol ChewDTO : Hashable, Codable {}

extension ChewDTO {
	static func warning(
		_ msg: String
	) {
		Logger.viewData.warning("\(Self.self): \(msg)")
	}
	static func error(
		_ msg: String
	) {
		Logger.viewData.error("\(Self.self): \(msg)")
	}
}
