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
	@ObservedObject var locationManager = Model.shared.locationDataManager
	@StateObject var nearestStopViewModel : NearestStopViewModel = NearestStopViewModel(
		.loadingNearbyStops(
			Model.shared.locationDataManager.location?.coordinate ?? .init()
		)
	)
	@State var nearestStops : [StopWithDistance] = []
	@State var selectedStop : StopWithDistance?
	@State var departures : [LegViewData]?
	
	let timerForNearbyStopsRequest = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
	let timerForRequestStopDetails = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
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
								event: .didRequestReloadStopDepartures(selectedStop.stop)
							)
						} else {
							nearestStopViewModel.send(
								event: .didDragMap(
									Model.shared.locationDataManager.location?.coordinate ?? .init()
								)
							)
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
//			#if DEBUG
//			Text("""
//					accuracy: \(Model.shared.locationDataManager.location?.horizontalAccuracy.description ?? "-")
//					ts: \(Model.shared.locationDataManager.location?.timestamp.timeIntervalSinceNow ?? -1) 
//					speed: \((Model.shared.locationDataManager.location?.speed ?? 0) * 3.6)
//				""")
//				.chewTextSize(.big)
//				.foregroundStyle(.secondary)
//				.padding(5)
//			#endif
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
										nearestStopViewModel.send(event: .didTapStopOnMap(stop.stop))
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
		.onAppear {
			Model.shared.locationDataManager.startUpdatingLocationAndHeading()
		}
		.onDisappear {
			Model.shared.locationDataManager.stopUpdatingLocationAndHeading()
		}
		.animation(.easeInOut, value: self.nearestStops)
		.animation(.easeInOut, value: self.selectedStop)
		.animation(.easeInOut, value: self.departures)
		.onReceive(nearestStopViewModel.$state, perform: { state in
			departures = state.data.selectedStopTrips
				Task {
					if let stop = state.data.selectedStop ,
					   let coord = locationManager.location?.coordinate {
						selectedStop = Self.updateDistanceToStop(
							from: coord,
							stop: stop
						)
					} else {
						selectedStop = nil
					}
					if let coord = locationManager.location?.coordinate {
						nearestStops = state.data.stops
							.map {
								Self.updateDistanceToStop(
									from: coord,
									stop: $0
								)
							}
							.sorted(by: {$0.distance ?? 0 < $1.distance ?? 0})
					}
				}
		})
		.onReceive(timerForNearbyStopsRequest, perform: { _ in
			if let coord = Model.shared.locationDataManager.location?.coordinate {
				nearestStopViewModel.send(
					event: .didDragMap(coord)
				)
			}
		})
		.onReceive(timerForRequestStopDetails, perform: { _ in
			if let stop = selectedStop {
				self.nearestStopViewModel.send(
					event: .didRequestReloadStopDepartures(stop.stop)
				)
			}
		})
		.onReceive(locationManager.$location, perform: { location in
			Task {
				if let cl2 = locationManager.location?.coordinate {
					if let stop = selectedStop {
						selectedStop = Self.updateDistanceToStop(
							from: cl2,
							stop: stop
						)
					}
					nearestStops = nearestStops
						.map {
							Self.updateDistanceToStop(
								from: cl2,
								stop: $0
							)
						}
						.sorted(by: {$0.distance ?? 0 < $1.distance ?? 0})
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
			HeadingView(target: stop.stop.coordinates.cllocation)
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
	static func updateDistanceToStop(
		from : CLLocationCoordinate2D,
		stop: Stop
	) -> StopWithDistance {
		let location = CLLocation(
			latitude: from.latitude,
			longitude: from.longitude
		)
		return StopWithDistance(
			stop: stop,
			distance: location.distance(
				CLLocationCoordinate2D(
					latitude: stop.coordinates.latitude,
					longitude: stop.coordinates.longitude
				)
			)
		)
	}
}

struct HeadingView : View {
	@ObservedObject var locationManager = Model.shared.locationDataManager
	@State var heading : Double?
	let target : CLLocation
	var body: some View {
		Group {
			if let heading = heading {
				ChooSFSymbols.arrowUpCircle.view
					.tint(.secondary)
					.rotationEffect(
						Angle(radians: heading)
					)
					.animation(.easeInOut, value: locationManager.heading?.trueHeading)
					.animation(.easeInOut, value: locationManager.location)
					.animation(.easeInOut, value: target)
			}
		}
		.onReceive(locationManager.$heading, perform: { _ in
			Task {
				if let loc = locationManager.location,
					let deg = locationManager.heading?.trueHeading {
					self.heading = loc.bearingRadianTo(location: target) - deg * .pi/180
				}
			}
		})
	}
}
//
//
//@ViewBuilder func stopWithDistance(stop : StopWithDistance) -> some View {
//	HStack(alignment: .center, spacing: 1) {
//		StopListCell(stop: stop)
//			.foregroundColor(.primary)
//		Spacer()
//		DistanceView(target: stop.stop.coordinates.cllocationcoordinates2d)
//		HeadingView(target: stop.stop.coordinates.cllocation)
//	}
//}
//


struct DistanceView : View {
	@ObservedObject var locationManager = Model.shared.locationDataManager
	@State var dist : Double?
	let target : CLLocationCoordinate2D
	var body: some View {
		Group {
			if let dist = dist {
				BadgeView(.distanceInMeters(dist: dist))
					.badgeBackgroundStyle(.secondary)
					.tint(Color.primary)
			}
		}
		.onReceive(locationManager.$location, perform: { location in
			Task {
				dist = location?.distance(target)
			}
		})
	}
}
