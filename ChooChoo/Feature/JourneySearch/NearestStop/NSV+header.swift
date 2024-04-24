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
		HStack {
			Text(
				"Stops Nearby",
				comment: "NearestStopView: view name"
			)
			.chewTextSize(.big)
			.padding(.leading,10)
//			.foregroundColor(.secondary)
			if let acc = locationManager.location?.horizontalAccuracy, acc < Self.enoughAccuracy {
				BadgeView(.generic(msg: "!"))
					.expandingBadge {
						OneLineText(Text(
							"Low location accuracy **\(Int(acc))**",
							comment: "NSV: location accuracy not precise")
						)
					}
					.chewTextSize(.medium)
					.badgeBackgroundStyle(.secondary)
					.foregroundStyle(.secondary)
					.frame(minWidth: 40)
			}
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
							.chewTextSize(.medium)
					default:
						ChooSFSymbols.arrowClockwise.view
							.foregroundStyle(.secondary)
					}
				}
				.frame(width: 40,height: 40)
			})
			Spacer()
		}
	}
}
