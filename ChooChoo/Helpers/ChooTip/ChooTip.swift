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
	case swipeActions
	case followJourney
	case journeySettingsFilterDisclaimer
	case sunEvents(onClose: () -> (), journey: JourneyViewData?)
	
	var description  : String {
		switch self {
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
			case .swipeActions:
				EmptyView()
			case .journeySettingsFilterDisclaimer:
				EmptyView()
			case .followJourney:
				EmptyView()
			case .sunEvents:
				SunEventsTipView(mode: .sunEvents)
			}
		}
		.padding(5)
	}
	
	@ViewBuilder var tipLabel : some View {
		switch self {
		case .swipeActions:
			Labels.SwipeActionsTip()
		case .journeySettingsFilterDisclaimer:
			Labels.JourneySettingsFilterDisclaimer()
		case .followJourney:
			HowToFollowJourneyView()
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
	}
}
