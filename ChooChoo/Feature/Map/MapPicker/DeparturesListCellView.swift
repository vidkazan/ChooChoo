//
//  DeparturesListCellView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.04.24.
//

import Foundation
import SwiftUI

struct DeparturesListCellView : View {
	let trip : LegViewData
	var body: some View {
		HStack(spacing: 0) {
			BadgeView(Badges.lineNumber(
				lineType: trip.lineViewData.type,
				num: trip.lineViewData.name)
			)
			.frame(minWidth: 80,alignment: .leading)
			BadgeView(Badges.legDirection(
				dir: trip.direction,
				strikethrough: trip.time.departureStatus == .cancelled,
				multiline: true
			))
			.frame(alignment: .leading)
			.tint(.primary)
			Spacer()
			TimeLabelView(
				size: .big,
				arragement: .left,
				delayStatus: trip.time.departureStatus,
				time: trip.time.date.departure
			)
			.frame(minWidth: 50)
			let platform = trip.legStopsViewData.first?.platforms.departure ?? trip.legStopsViewData.last?.platforms.arrival
			HStack {
				if let platform = platform  {
					PlatformView(isShowingPlatormWord: false, platform: platform)
				}
			}
			.frame(minWidth: 45)
		}
		.frame(minHeight : 30)
	}
}
