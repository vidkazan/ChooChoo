//
//  JourneyActions.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.08.24.
//

import Foundation


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
		
		func time(time : TimeContainer) -> Prognosed<Date> {
			switch self {
			case .enter:
				return time.date.departure
			case .exit:
				return time.date.arrival
			}
		}
	}
	
	struct JourneyAction : Hashable {
		let type : JourneyActionType
		let leg : LegViewData
		let stopData : StopViewData
	}
}
