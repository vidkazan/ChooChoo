//
//  Settings.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation
import SwiftUI

struct AppSettings : Hashable, Codable {
	let debugSettings : ChewDebugSettings
	let legViewMode : LegViewMode
	let tipsToShow : Set<ChooTip.TipType>
	init(debugSettings : ChewDebugSettings,
		legViewMode : LegViewMode,
		tips : Set<ChooTip.TipType>
	) {
		self.legViewMode = legViewMode
		self.tipsToShow = tips
		self.debugSettings = debugSettings
	}
	
	init(oldSettings : Self,
		debugSettings : ChewDebugSettings? = nil,
		legViewMode : LegViewMode? = nil,
		tips : Set<ChooTip.TipType>? = nil
	) {
		self.legViewMode = legViewMode ?? oldSettings.legViewMode
		self.tipsToShow = tips ?? oldSettings.tipsToShow
		self.debugSettings = debugSettings ?? oldSettings.debugSettings
	}
	
	init() {
		self.legViewMode = .colorfulLegs
		self.tipsToShow = Set(ChooTip.TipType.allCases)
		self.debugSettings = ChewDebugSettings(prettyJSON: false, alternativeSearchPage: false)
	}
}

extension AppSettings {
	struct ChewDebugSettings: Hashable, Codable {
		let prettyJSON : Bool
		let alternativeSearchPage : Bool
	}
	
	enum LegViewMode : Int16, Hashable,CaseIterable, Codable {
		case sunEvents
		case colorfulLegs
		case all
		
		var description : [String] {
			switch self {
			case .sunEvents:
				return [NSLocalizedString("sunlight / moonlight color", comment: "AppSettings: LegViewMode: description")]
			case .colorfulLegs:
				return [NSLocalizedString("transport type color", comment: "AppSettings: LegViewMode: description")]
			case .all:
				return Array(
					Self.colorfulLegs.description
					+
					Self.sunEvents.description
				)
			}
		}
		
		var showSunEvents : Bool {
			self != .colorfulLegs
		}
		var showColorfulLegs : Bool {
			self != .sunEvents
		}
	}
}

extension AppSettings {
	func showTip(tip : ChooTip.TipType) -> Bool {
		if !tipsToShow.contains(tip) {
			return false
		}
		switch tip {
		case .journeySettingsFilterDisclaimer,.followJourney,.swipeActions,.mapPickerLocationPick:
			return true
		case .sunEventsTip:
			if self.legViewMode != .colorfulLegs {
				return true
			}
			return false
		}
	}
}
