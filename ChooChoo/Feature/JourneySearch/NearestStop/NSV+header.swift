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
			.foregroundColor(.secondary)
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
				ReloadableButtonLabel(state: {
					switch nearestStopViewModel.state.status {
					case .loadingStopDetails,.loadingNearbyStops:
						return .loading
					case .idle:
						return .idle
					case .error:
						return .error
					}
				}())
				.frame(minWidth: 30,minHeight: 30)
				.chewTextSize(.big)
				.foregroundStyle(.secondary)
			})
			if selectedStop == nil {
				if let acc = locationManager.location?.horizontalAccuracy, acc > Self.enoughAccuracy {
					BadgeView(.remarkImportant(remarks: []))
						.expandingBadge {
							HStack(spacing: 0) {
								Text(
									"Low accuracy:",
									comment: "NSV: location accuracy not precise"
								)
								BadgeView(.distance(dist: acc))
							}
						}
						.chewTextSize(.medium)
						.badgeBackgroundStyle(.secondary)
						.foregroundStyle(.secondary)
						.transition(.opacity)
				}
			} else if selectedStop != nil, !departuresTypes.isEmpty {
				trasportFilter()
			}
			Spacer()
		}
		.animation(.easeInOut, value: locationManager.location?.horizontalAccuracy)
		.padding(.leading,10)
	}
}

extension NearestStopView {
	func trasportFilter() -> some View {
		HStack(spacing: 5) {
				ForEach(
					Array(departuresTypes).sorted(by: <),
					id:\.hashValue
				) { type in
					Button(
						action: {
							filteredLineType = filteredLineType == type ? nil : type
						},
						label: {
							Image(type.iconBig)
								.frame(minWidth: 28,maxWidth: 28)
								.opacity(filteredLineType == type ? 1 : 0.3)
						})
				}
			}
		.chewTextSize(.medium)
//		.badgeBackgroundStyle(.secondary)
		.foregroundStyle(.secondary)
		.transition(.opacity)
	}
}
