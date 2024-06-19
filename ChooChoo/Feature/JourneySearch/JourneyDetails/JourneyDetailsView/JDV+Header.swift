//
//  JourneyDetails.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import SwiftUI
import ChooViews

extension JourneyDetailsView {
	func header() -> some View {
		VStack(alignment: .leading) {
			let data = viewModel.state.data
			VStack(alignment: .leading) {
				BadgeView(
					.departureArrivalStops(
						departure: data.viewData.origin,
						arrival: data.viewData.destination
					),
					.huge
				)
				if #available(iOS 16.0, *) {
					FlowLayout(spacing: CGSize(width: 5, height: 2)) {
						time(data: data)
					}
				} else {
					HStack {
						time(data: data)
						Spacer()
					}
				}
				LegsView(
					journey : viewModel.state.data.viewData,
					mode : appSettingsVM.state.settings.legViewMode,
					legTapAction: { id in
						scrollToLegId = id
					}
				)
			}
			
		}
	}
	
	private func time(data : JourneyDetailsViewModel.StateData) -> some View {
		Group {
			if let date = data.viewData.time.date.departure.actualOrPlannedIfActualIsNil() {
				BadgeView(.date(date: date))
					.badgeBackgroundStyle(.accent)
			}
			BadgeView(
				.timeDepartureTimeArrival(
					timeContainer: data.viewData.time
				)
			)
				.badgeBackgroundStyle(.accent)
			BadgeView(
				.legDuration(
					data.viewData.time
				)
			)
				.badgeBackgroundStyle(.accent)
			if viewModel.state.data.viewData.transferCount > 0 {
				BadgeView(.changesCount(data.viewData.transferCount))
					.badgeBackgroundStyle(.accent)
			}
		}
	}
}
