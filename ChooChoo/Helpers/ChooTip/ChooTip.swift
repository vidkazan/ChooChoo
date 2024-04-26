//
//  ChooTip.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 24.04.24.
//

import Foundation
import SwiftUI


enum ChooTip : Hashable {
	static func == (lhs: ChooTip, rhs: ChooTip) -> Bool {
		lhs.description == rhs.description
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(description)
	}
	case mapPickerLocationPick(onClose: () -> ())
	case swipeActions
	case followJourney
	case journeySettingsFilterDisclaimer
	case sunEvents(onClose: () -> (), journey: JourneyViewData?)
	
	var description  : String {
		switch self {
		case .mapPickerLocationPick:
			return "mapPickerLocationPick"
		case .swipeActions:
			return "swipe actions"
		case .journeySettingsFilterDisclaimer:
			return "journeySettingsFilterDisclaimer"
		case .followJourney:
			return "followJourney"
		case .sunEvents:
			return "sunEvents"
		}
	}
	
	@ViewBuilder var tipView : some View  {
		Group {
			switch self {
			case .mapPickerLocationPick,
					.swipeActions,
					.journeySettingsFilterDisclaimer,
					.followJourney:
				EmptyView()
			case .sunEvents:
				SunEventsTipView(mode: .sunEvents)
			}
		}
		.padding(5)
	}
	
	@ViewBuilder var tipLabel : some View {
		switch self {
		case .mapPickerLocationPick(let onClose):
			Labels.MapPickerLocationPickTipView(onClose: onClose)
		case .swipeActions:
			Labels.SwipeActionsTip()
		case .journeySettingsFilterDisclaimer:
			Labels.JourneySettingsFilterDisclaimer()
		case .followJourney:
			Labels.HowToFollowJourneyView()
		case let .sunEvents(close, journey):
			Labels.SunEventsTip(onClose: close, journey: journey)
		}
	}
}

extension ChooTip {
	enum TipType : String ,Hashable, CaseIterable,Codable {
		case journeySettingsFilterDisclaimer
		case followJourney
		case sunEventsTip
		case swipeActions
		case mapPickerLocationPick
	}
}
