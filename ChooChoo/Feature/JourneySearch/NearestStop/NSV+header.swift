//
//  NSV+subviews.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI

extension NearestStopView {
	@ViewBuilder func header() -> some View {
		HStack(spacing: 2) {
			if let acc = locationManager.location?.horizontalAccuracy, acc > Self.enoughAccuracy {
				BadgeView(.generic(msg: "!"))
					.expandingBadge {
						OneLineText(Text(
							"Low accuracy: +/-**\(Int(acc/2))m**",
							comment: "NSV: location accuracy not precise")
						)
					}
					.chewTextSize(.medium)
					.badgeBackgroundStyle(.secondary)
					.foregroundStyle(.secondary)
					.frame(minWidth: 40)
			}
			Text(
				"Stops Nearby",
				comment: "NearestStopView: view name"
			)
			.padding(10)
			.chewTextSize(.big)
			Button(action: {
				switch nearestStopViewModel.state.status {
				case .loadingStopDetails,.loadingNearbyStops:
					nearestStopViewModel.send(event: .didCancelLoading)
				default:
					if let selectedStop = selectedStop {
						nearestStopViewModel.send(
							event: .didRequestReloadStopDepartures(selectedStop.stop)
						)
					} else {
						nearestStopViewModel.send(
							event: .didDragMap(
								Model.shared.locationDataManager.location ?? .init()
							)
						)
					}
				}
			}, label: {
				Group {
					switch nearestStopViewModel.state.status {
					case .loadingStopDetails,
							.loadingNearbyStops:
						ProgressView()
					default:
						ChooSFSymbols.arrowClockwise.view
					}
				}
				.chewTextSize(.big)
				.foregroundStyle(.secondary)
			})
			Spacer()
		}
	}
}
