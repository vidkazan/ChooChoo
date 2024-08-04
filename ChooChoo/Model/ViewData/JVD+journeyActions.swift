//
//  JVD+journeyActions.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 04.08.24.
//

import Foundation

extension JourneyViewData {
	func journeyActions() -> [JourneyFollowData.JourneyAction] {
		var legs = legs
		
		let last =  legs.removeLast()
		var res : [JourneyFollowData.JourneyAction] = legs.compactMap { leg in
			if leg.legType == .line {
				if let firstStop = leg.legStopsViewData.first {
					return JourneyFollowData.JourneyAction(
						type: .enter,
						leg: leg,
						stopData: firstStop
					)
				}
				return nil
			}
			return nil
		}
		if let lastStop = last.legStopsViewData.last,
		   let firstStop = last.legStopsViewData.first {
			let lastRes = {
				[
					JourneyFollowData.JourneyAction(
						type: .enter,
						leg: last,
						stopData: firstStop
					),
					JourneyFollowData.JourneyAction(
						type: .exit,
						leg: last,
						stopData: lastStop
					)
				 ]
			}()
			res += lastRes
		}
		return res
	}
}
