//
//  ChooDeparture.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 01.08.24.
//

import Foundation

enum ChooDeparture : Hashable {
	case location(Stop)
	case transport(LegViewData)

	var stop : Stop? {
		switch self {
		case .location(let stop):
			return stop
		case .transport(let leg):
			return JourneyAlternativeDepartureStopViewModel.getCurrentLegAlternativeJourneyDepartureStop(leg: leg, referenceDate: .now)?.alternativeDeparture.stopViewData.stop()
		}
	}
	
	var leg : LegViewData? {
		switch self {
		case .location:
			return nil
		case .transport(let leg):
			return leg
		}
	}
}
