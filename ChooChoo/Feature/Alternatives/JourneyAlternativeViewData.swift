//
//  JourneyAlternativeViewData.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 15.07.24.
//

import Foundation
import SwiftUI

enum AlternativeStopPosition : Hashable {
	case onStop
	case headingToStop(time : Date)
		
	func timeBadge(referenceDate : ChewDate) -> Text? {
		switch self {
		case .onStop:
			return Text("now", comment: "AlternativeStopPosition: timeBadge")
		case .headingToStop(let time):
			if let min = DateParcer.getTwoDateIntervalInMinutes(date1: referenceDate.date, date2: time) {
			   switch min {
			   case 0..<1:
				   return Text("now", comment: "JourneyAlternativesView")
			   default:
				   if let dur = DateParcer.timeDuration(min) {
					   return Text("in \(dur)", comment: "JourneyAlternativesView")
				   }
				   return nil
			   }
			}
			return nil
		}
	}
	var description : String {
		switch self {
		case .headingToStop:
			"headingToStop"
		case .onStop:
			"onStop"
		}
	}
}

enum AlternativeStop : Hashable {
	case stop(stop : StopViewData)
	case onTransport(nearestStop : StopViewData,leg : LegViewData)
	
	var stopViewData : StopViewData {
		switch self {
		case .stop(let stop):
			return stop
		case let .onTransport(stop, _):
			return stop
		}
	}
	
	var leg : LegViewData? {
		switch self {
		case .stop:
			return nil
		case let .onTransport(_, leg):
			return leg
		}
	}
	
	var description : String {
		switch self {
		case .stop:
			"stop"
		case .onTransport:
			"onTransport"
		}
	}
}

enum JourneyAlternativeCase : Hashable {
	case nowBeforeDeparture
	case lastReachableLeg
	case currentLeg
	case currentLegArrivalStopCancelled
	case undefined

	
	var description : String {
		switch self {
		case .nowBeforeDeparture:
			return "nowBeforeDeparture"
		case .lastReachableLeg:
			return "lastReachableLeg"
		case .currentLeg:
			return "currentLeg"
		case .currentLegArrivalStopCancelled:
			return "currentLegArrivalStopCancelled"
		case .undefined:
			return "undefined"
		}
	}
}

struct JourneyAlternativeViewData : Hashable {
	let alternativeCase : JourneyAlternativeCase
	let alternativeDeparture : AlternativeStop
	let alternativeStopPosition : AlternativeStopPosition
}
