//
//  NearestStopView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 19.04.24.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

struct NearestStopView : View {
	@Namespace var nearestStopView
	@EnvironmentObject var chewVM : ChewViewModel
	@StateObject var nearestStopViewModel : NearestStopViewModel = NearestStopViewModel(
		.loadingNearbyStops(
			.init(
				center: Model.shared.locationDataManager.locationManager.location?.coordinate ?? .init(),
				latitudinalMeters: 0.01,
				longitudinalMeters: 0.01
			)
		)
	)
	@State var nearestStops : [StopWithDistance] = []
	@State var selectedStop : StopWithDistance?
	@State var departures : [LegViewData]?
	
	let timerForNearbyStopsRequest = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
	let timerForRequestStopDetails = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	let timerInner = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	var body: some View {
		VStack(alignment: .leading,spacing: 2) {
			HStack {
				Text(
					"Stops Nearby",
					comment: "NearestStopView: view name"
				)
				.chewTextSize(.big)
				.offset(x: 10)
				.foregroundColor(.secondary)
				Button(action: {
					switch nearestStopViewModel.state.status {
					case .loadingStopDetails,.loadingNearbyStops:
						nearestStopViewModel.send(event: .didCancelLoading)
					default:
						if let selectedStop = selectedStop {
							nearestStopViewModel.send(
								event: .didRequestReloadStopDepartures(selectedStop)
							)
						} else {
							nearestStopViewModel.send(event: .didDragMap(
								.init(
									center: Model.shared.locationDataManager.locationManager.location?.coordinate ?? .init(),
									latitudinalMeters: 0.01,
									longitudinalMeters: 0.01
								)
							))
						}
					}
				},
					   label: {
					switch nearestStopViewModel.state.status {
					case .loadingStopDetails,
							.loadingNearbyStops:
						ProgressView()
							.frame(width: 40,height: 40)
							.chewTextSize(.medium)
					default:
						ChooSFSymbols.arrowClockwise.view
							.foregroundStyle(.secondary)
							.frame(width: 40,height: 40)
					}
				})
			}
			ScrollView(showsIndicators: false) {
				VStack(spacing:0) {
					if let stop = selectedStop {
						VStack(spacing:0) {
							HStack(alignment: .center, spacing: 1) {
								Button(action: {
									nearestStopViewModel.send(event: .didDeselectStop)
								}, label: {
									ChooSFSymbols.arrowLeft.view
								})
								.frame(width: 40, height: 40)
								stopWithDistance(stop: stop)
							}
							if let trips = departures {
								ForEach(trips,id: \.hashValue) { trip in
									Button(action: {
										Model.shared.sheetViewModel.send(
											event: .didRequestShow(.route(leg: trip))
										)
									}, label: {
										DeparturesListCellView(trip: trip)
									})
								}
							}
						}
						.transition(.move(edge: .trailing))
					} else {
						if !nearestStops.isEmpty {
							VStack(spacing:0) {
								ForEach(
									nearestStops,
									id: \.hashValue
								) { stop in
									Button(action: {
										nearestStopViewModel.send(event: .didTapStopOnMap(stop))
									},
									label: {
										stopWithDistance(stop: stop)
											.matchedGeometryEffect(
												id: stop.stop.name,
												in: nearestStopView
											)
									})
								}
							}
							.transition(.move(edge: .leading))
						}
					}
				}
				.frame(maxWidth: .infinity)
			}
			.padding(5)
			.background(Color.chewFillAccent.opacity(0.5))
			.clipShape(.rect(cornerRadius: 8))
			.frame(maxWidth: .infinity,maxHeight: 150)
		}
		.animation(.easeInOut, value: self.nearestStops)
		.animation(.easeInOut, value: self.selectedStop)
		.animation(.easeInOut, value: self.departures)
		.onReceive(nearestStopViewModel.$state, perform: { state in
			nearestStops = state.data.stops
			selectedStop = state.data.selectedStop
			departures = state.data.selectedStopTrips
		})
		.onReceive(timerForNearbyStopsRequest, perform: { _ in
			if let coord = Model.shared.locationDataManager.locationManager.location?.coordinate {
				nearestStopViewModel.send(
					event: .didDragMap(
						.init(
							center: coord,
							latitudinalMeters: 0.02,
							longitudinalMeters: 0.02
						)
					)
				)
			}
		})
		.onReceive(timerForRequestStopDetails, perform: { _ in
			if let stop = selectedStop {
				self.nearestStopViewModel.send(
					event: .didRequestReloadStopDepartures(stop)
				)
			}
		})
		.onReceive(timerInner, perform: { _ in
			Task {
				if let cl2 = Model
					.shared
					.locationDataManager
					.locationManager
					.location?
					.coordinate {
					if let stop = selectedStop {
						selectedStop = Self.updateDistanceToStop(
							from: cl2,
							stop: stop
						)
					}
					nearestStops = nearestStops.map {
						Self.updateDistanceToStop(
							from: cl2,
							stop: $0
						)
					}
				}
			}
		})
	}
	
	@ViewBuilder func stopWithDistance(stop : StopWithDistance) -> some View {
		HStack(alignment: .center, spacing: 1) {
			StopListCell(stop: stop)
				.foregroundColor(.primary)
			Spacer()
			if let dist = stop.distance {
				BadgeView(.distanceInMeters(dist: dist))
					.badgeBackgroundStyle(.secondary)
					.tint(Color.primary)
			}
		}
	}
	
	static func updateDistanceToStop(
		from : CLLocationCoordinate2D,
		stop: StopWithDistance
	) -> StopWithDistance {
		let location = CLLocation(
			latitude: from.latitude,
			longitude: from.longitude
		)
		return StopWithDistance(
			stop: stop.stop,
			distance: location.distance(
				CLLocationCoordinate2D(
					latitude: stop.stop.coordinates.latitude,
					longitude: stop.stop.coordinates.longitude
				)
			)
		)
	}

}
