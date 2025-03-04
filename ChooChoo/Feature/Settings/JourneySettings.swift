//
//  Settings.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation
import SwiftUI

class JourneySettingsClass : ObservableObject {
	@Published var customTransferModes : Set<LineType>
	@Published var transportMode : JourneySettings.TransportMode
	@Published var transferTime : JourneySettings.TransferTime
	@Published var transferCount : JourneySettings.TransferCountCases
	@Published var accessiblity : JourneySettings.Accessiblity
	@Published var walkingSpeed : JourneySettings.WalkingSpeed
	@Published var startWithWalking : Bool
	@Published var withBicycle : Bool
    @Published var fastestConnections : Bool
	
	init(
		customTransferModes: Set<LineType>,
		transportMode: JourneySettings.TransportMode,
		transferTime: JourneySettings.TransferTime,
		transferCount: JourneySettings.TransferCountCases,
		accessiblity: JourneySettings.Accessiblity,
		walkingSpeed: JourneySettings.WalkingSpeed,
		startWithWalking: Bool,
		withBicycle: Bool,
        fastestConnections : Bool
	) {
		self.customTransferModes = customTransferModes
		self.transportMode = transportMode
		self.transferTime = transferTime
		self.transferCount = transferCount
		self.accessiblity = accessiblity
		self.walkingSpeed = walkingSpeed
		self.startWithWalking = startWithWalking
		self.withBicycle = withBicycle
        self.fastestConnections = fastestConnections
	}
	
	convenience init(settings : JourneySettings) {
		self.init(
			customTransferModes: settings.customTransferModes,
			transportMode: settings.transportMode,
			transferTime: settings.transferTime,
			transferCount: settings.transferCount,
			accessiblity: settings.accessiblity,
			walkingSpeed: settings.walkingSpeed,
			startWithWalking: settings.startWithWalking,
			withBicycle: settings.withBicycle,
            fastestConnections: settings.fastestConnections
		)
	}
}

struct JourneySettings : Hashable,Codable {
	let customTransferModes : Set<LineType>
	let transportMode : TransportMode
	let transferTime : TransferTime
	let transferCount : TransferCountCases
	let accessiblity : Accessiblity
	let walkingSpeed : WalkingSpeed
	let startWithWalking : Bool
	let withBicycle : Bool
    let fastestConnections : Bool
	
	init(customTransferModes: Set<LineType>, transportMode: TransportMode, transferTime: TransferTime, transferCount: TransferCountCases, accessiblity: Accessiblity, walkingSpeed: WalkingSpeed, startWithWalking: Bool, withBicycle: Bool,fastestConnections : Bool) {
		self.customTransferModes = customTransferModes
		self.transportMode = transportMode
		self.transferTime = transferTime
		self.transferCount = transferCount
		self.accessiblity = accessiblity
		self.walkingSpeed = walkingSpeed
		self.startWithWalking = startWithWalking
		self.withBicycle = withBicycle
        self.fastestConnections = fastestConnections
	}
	
	init(settings : JourneySettingsClass) {
		self.init(
			customTransferModes: settings.customTransferModes,
			transportMode: settings.transportMode,
			transferTime: settings.transferTime,
			transferCount: settings.transferCount,
			accessiblity: settings.accessiblity,
			walkingSpeed: settings.walkingSpeed,
			startWithWalking: settings.startWithWalking,
			withBicycle: settings.withBicycle,
            fastestConnections: settings.fastestConnections
		)
	}
}

extension JourneySettings {
	var iconBadge : IconBadge {
		get {
			if !isDefault() {
				return .redDot
			}
			if transportMode == .regional {
				return .regional
			}
			return .empty
		}
	}
}

extension JourneySettingsClass {
	func isDefault() -> Bool {
		guard transportMode == .regional
				||
				transportMode == .all
				||
				( transportMode == .custom && customTransferModes.count > 6 )
		else {
			return false
		}
		guard transferTime == transferTime.defaultValue else {
			return false
		}
		guard transferCount == transferCount.defaultValue else {
			return false
		}
		guard startWithWalking == true else {
			return false
		}
		guard withBicycle == false else {
			return false
		}
		return true
	}
}


extension JourneySettings {
	func isDefault() -> Bool {
		guard transportMode == .regional
				||
				transportMode == .all
				||
				( transportMode == .custom && customTransferModes.count > 6 )
		else {
			return false
		}
		guard transferTime == transferTime.defaultValue else {
			return false
		}
		guard transferCount == transferCount.defaultValue else {
			return false
		}
		guard startWithWalking == true else {
			return false
		}
		guard withBicycle == false else {
			return false
		}
		return true
	}
}

extension JourneySettings {
	enum IconBadge {
		case empty
		case regional
		case redDot
		
		@ViewBuilder var view : some View {
			Group {
				switch self {
				case .empty:
					EmptyView()
				case .regional:
					Circle()
						.fill(Color.chewFillTertiary)
						.frame(width: 14,height: 14)
						.overlay {
							Image("re")
								.chewTextSize(.small)
								.tint(.primary)
						}
				case .redDot:
					Circle()
						.fill(Color.chewFillRedPrimary)
						.frame(width: 12,height: 12)
				}
			}
		}
	}

}
