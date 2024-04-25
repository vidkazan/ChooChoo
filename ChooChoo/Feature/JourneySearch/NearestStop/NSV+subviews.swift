//
//  NSV+subviews.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI

extension NearestStopView {
	@ViewBuilder func stopWithDistance(stop : StopWithDistance) -> some View {
		HStack(alignment: .center, spacing: 1) {
			StopListCell(stop: stop)
				.foregroundColor(.primary)
			Spacer()
			if let dist = stop.distance {
				BadgeView(.distance(dist: dist))
					.badgeBackgroundStyle(.secondary)
					.tint(Color.primary)
			}
			HeadingView(targetStopLocation: stop.stop.coordinates.cllocation)
		}
	}
}
