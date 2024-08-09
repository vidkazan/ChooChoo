//
//  View+LocalizedString.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 30.07.24.
//

import Foundation
import SwiftUI

extension View {
	func localisedString( _ key: String,
		comment: String) -> String {
		NSLocalizedString(key, comment: "\(Self.self) \(comment)")
	}
}
