//
//  JourneyHeaderView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 26.08.23.
//

import SwiftUI
import ChooViews

struct JourneyHeaderView: View {
	let journey : JourneyViewData
	
	var body: some View {
		HStack {
			TimeLabelView(
				size: .big,
				arragement: .right,
				time : journey.time.date.departure,
				delayStatus: journey.time.departureStatus
			)
			.padding(7)
			Spacer()
			TimeLabelView(
				size: .big,
				arragement: .left,
				time : journey.time.date.arrival,
				delayStatus: journey.time.arrivalStatus
			)
			.padding(7)
		}
		.overlay {
			BadgeView(.legDuration(journey.time))
				.foregroundColor(.primary)
				.chewTextSize(.medium)
		}
		.frame(maxWidth: .infinity,maxHeight: 40)
		.cornerRadius(10)
	}
}
