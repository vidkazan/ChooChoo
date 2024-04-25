//
//  SearchStopsView+StopList.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import CoreLocation
import Foundation
import SwiftUI

extension SearchStopsView {
	func recentStops(
		type : LocationDirectionType,
		recentStops : [StopWithDistance]
	) -> some View {
		Group {
			if !recentStops.isEmpty {
				ForEach(recentStops,id: \.distance) { stop in
					HStack(alignment: .center) {
						Button(action: {
							switch type {
							case .departure:
								chewViewModel.send(event: .didUpdateSearchData(dep: .location(stop.stop)))
							case .arrival:
								chewViewModel.send(event: .didUpdateSearchData(arr: .location(stop.stop)))
							}
							searchStopViewModel.send(event: .onStopDidTap(.location(stop.stop), type))
						}, label: {
							StopListCell(stop: stop)
						})
						.foregroundColor(.primary)
						Spacer()
						Button(action: {
							deleteStop(stop: stop, type: type)
						}, label: {
							Image(.xmarkCircle)
								.foregroundColor(.primary)
								.chewTextSize(.big)
						})
						.frame(height: 40)
						Image(.clockArrowCirclepath)
							.chewTextSize(.big)
							.foregroundColor(.chewGrayScale30)
							.padding(.horizontal,7)
							.frame(height: 40)
							.foregroundColor(.primary)
					}
				}
			}
		}
	}
}

extension SearchStopsView {
	func foundStop(
		type : LocationDirectionType,
		stops : [StopWithDistance]
	) -> some View {
		Group {
			switch searchStopViewModel.state.status {
			case .loaded,.updatingRecentStops,.loading:
				if !searchStopViewModel.state.stops.isEmpty {
					ScrollView {
						VStack(spacing: 0) {
							ForEach(stops,id:\.distance) { stop in
								HStack(alignment: .center, spacing: 1) {
									Button(
										action: {
											Task {
												tapStop(stop: stop,type: type)
											}
										},
										label: {
											StopListCell(stop: stop)
										}
									)
									.foregroundColor(.primary)
									Spacer()
									if let dist = stop.distance {
										BadgeView(.distance(dist: dist))
											.badgeBackgroundStyle(.primary)
									}
								}
							}
						}
					}
					.frame(maxHeight: 300)
				}
			case .error(let error):
				Text(verbatim: error.localizedDescription)
					.chewTextSize(.big)
					.foregroundColor(.secondary)
					.padding(5)
					.frame(maxWidth: .infinity,alignment: .center)
			case .idle:
				EmptyView()
			}
		}
	}
}

extension SearchStopsView {
	func tapStop(stop : StopWithDistance, type : LocationDirectionType) {
		Task {
			if !searchStopViewModel
				.state
				.previousStops
				.contains(where: {$0.id == stop.stop.id}) {
				Model
					.shared
					.coreDataStore
					.addRecentLocation(stop: stop.stop)
			}
			switch type {
			case .departure:
				chewViewModel.send(event: .didUpdateSearchData(dep: .location(stop.stop)))
			case .arrival:
				chewViewModel.send(event: .didUpdateSearchData(arr: .location(stop.stop)))
			}
			searchStopViewModel
				.send(event: .onStopDidTap(.location(stop.stop), type))
		}
	}
	
	func deleteStop(stop : StopWithDistance, type : LocationDirectionType) {
		Task {
			if searchStopViewModel
				.state
				.previousStops
				.contains(where: {$0.name == stop.stop.name}),
			   Model
				.shared
				.coreDataStore
				.deleteRecentLocationIfFound(name: stop.stop.name) == true {
				searchStopViewModel.send(
					event: .didRequestDeleteRecentStop(stop: stop.stop)
				)
			}
		}
	}
}
