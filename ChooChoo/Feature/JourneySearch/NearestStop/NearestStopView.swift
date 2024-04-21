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

#warning("animations")
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
	
	let timerForRequest = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
	let timerInner = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	var body: some View {
		VStack {
			if !nearestStops.isEmpty {
				VStack(alignment: .leading,spacing: 2) {
					HStack {
						Text(
							"Stops Nearby",
							comment: "NearestStopView: view name"
						)
						.chewTextSize(.big)
						.offset(x: 10)
						.foregroundColor(.secondary)
						switch nearestStopViewModel.state.status {
						case .loadingStopDetails:
							ProgressView()
								.frame(width: 40,height: 40)
								.chewTextSize(.medium)
						default:
							Button(action: {
								nearestStopViewModel.send(event: .didDragMap(
									.init(
										center: Model.shared.locationDataManager.locationManager.location?.coordinate ?? .init(),
										latitudinalMeters: 0.01,
										longitudinalMeters: 0.01
									)
								))
							}, label: {
								ChooSFSymbols.arrowClockwise.view
									.foregroundStyle(.secondary)
									.frame(width: 40,height: 40)
							})
						}
					}
					ScrollView(showsIndicators: false) {
						VStack(spacing:0) {
							if let trips = departures,
							   let stop = selectedStop
							{
								VStack(spacing:0) {
									HStack(alignment: .center, spacing: 1) {
										Button(action: {
											nearestStopViewModel.send(event: .didDeselectStop)
										}, label: {
											ChooSFSymbols.arrowLeft.view
										})
										.frame(width: 40, height: 40)
										stopWithDistance(stop: stop)
											.matchedGeometryEffect(id: stop.stop.name, in: nearestStopView)
									}
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
							} else {
								if !nearestStops.isEmpty {
									VStack(spacing:0) {
										ForEach(
											nearestStops,
											id: \.hashValue
										) { stop in
											Button(action: {
												nearestStopViewModel.send(event: .didTapStopOnMap(stop, send: {_ in}))
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
								}
							}
						}
					}
					.animation(.easeInOut, value: self.nearestStops)
					.animation(.easeInOut, value: self.selectedStop)
					.animation(.easeInOut, value: self.departures)
					.padding(5)
					.background(Color.chewFillAccent.opacity(0.5))
					.clipShape(.rect(cornerRadius: 8))
					.frame(maxWidth: .infinity,maxHeight: 150)
				}
			}
		}
		.onReceive(nearestStopViewModel.$state, perform: { state in
			nearestStops = state.data.stops
			selectedStop = state.data.selectedStop
			departures = state.data.selectedStopTrips
		})
		.onReceive(timerForRequest, perform: { _ in
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
