//
//  Settings.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation

extension JourneySettings {
	init() {
		self.customTransferModes = []
		self.accessiblity = .partial
		self.startWithWalking = true
		self.transferTime = .time(minutes: .zero)
		self.transportMode = .all
		self.walkingSpeed = .fast
		self.withBicycle = false
		self.transferCount = .unlimited
	}
	init(settings : JourneySettings) {
		self.customTransferModes = settings.customTransferModes
		self.accessiblity = settings.accessiblity
		self.startWithWalking = settings.startWithWalking
		self.transferTime = settings.transferTime
		self.transportMode = settings.transportMode
		self.walkingSpeed = settings.walkingSpeed
		self.withBicycle = settings.withBicycle
		self.transferCount = settings.transferCount
	}
}
