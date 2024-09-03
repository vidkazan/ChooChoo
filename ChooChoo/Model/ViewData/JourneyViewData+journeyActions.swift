//
//  JVD+journeyActions.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 04.08.24.
//

import Foundation

extension JourneyViewData {
	func journeyActions() -> [JourneyFollowData.JourneyAction] {
		
		var res : [JourneyFollowData.JourneyAction] = []
		
		legs.forEach { leg in
			if leg.legType == .line {
				if let lastStop = leg.legStopsViewData.last,
				   let firstStop = leg.legStopsViewData.first {
					let lastRes = {
						[
							JourneyFollowData.JourneyAction(
								type: .enter,
								leg: leg,
								stopData: firstStop
							),
							JourneyFollowData.JourneyAction(
								type: .exit,
								leg: leg,
								stopData: lastStop
							)
						 ]
					}()
					res += lastRes
				}
			}
		}
		return res
	}
}
