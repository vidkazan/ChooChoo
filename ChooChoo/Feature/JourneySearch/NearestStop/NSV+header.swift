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
				Group {
					switch nearestStopViewModel.state.status {
					case .loadingStopDetails,.loadingNearbyStops:
						ProgressView()
					default:
						ChooSFSymbols.arrowClockwise.view
					}
				}
				.frame(minWidth: 30,minHeight: 30)
				.chewTextSize(.big)
				.foregroundStyle(.secondary)
			})
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
			if selectedStop != nil, !departuresTypes.isEmpty {
				BadgeView(.generic(msg: ">"))
					.expandingBadge {
						HStack(spacing: 3) {
							ForEach(Array(departuresTypes),id:\.hashValue) { type in
								Button(
									action: {
										if filteredLineType == type {
											filteredLineType = nil
										} else {
											filteredLineType = type
										}
									},
									label: {
										Image(type.iconBig)
											.frame(minWidth: 25,maxWidth: 25)
											.opacity(filteredLineType == type ? 1 : 0.3)
									})
								.frame(minWidth: 40,maxWidth: 40)
							}
						}
					}
					.chewTextSize(.medium)
					.badgeBackgroundStyle(.secondary)
					.foregroundStyle(.secondary)
					.transition(.opacity)
			}
			Spacer()
		}
		.animation(.easeInOut, value: locationManager.location?.horizontalAccuracy)
		.padding(.leading,10)
	}
}
