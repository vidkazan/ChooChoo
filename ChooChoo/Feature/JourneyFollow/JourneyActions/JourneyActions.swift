//
//  JourneyActions.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.08.24.
//

import Foundation
import SwiftUI

extension JourneyFollowData {
	enum JourneyActionType : Hashable {
		case enter // | ->
		case exit // -> |
		
		func platform(platform : StopViewData.Platforms) -> Prognosed<String> {
			switch self {
			case .enter:
				return platform.departure
			case .exit:
				return platform.arrival
			}
		}
		
		func time(time : TimeContainer) -> Date? {
			switch self {
			case .enter:
				return time.date.departure.actualOrPlannedIfActualIsNil()
			case .exit:
				return time.date.arrival.actualOrPlannedIfActualIsNil()
			}
		}
		
		func text() -> Text {
			switch self {
			case .enter:
				return Text("", comment: "JourneyActionType")
			case .exit:
				return Text("exit at ", comment: "JourneyActionType")
			}
		}
	}
	
	struct JourneyAction : Hashable {
		let type : JourneyActionType
		let leg : LegViewData
		let stopData : StopViewData
	}
}
