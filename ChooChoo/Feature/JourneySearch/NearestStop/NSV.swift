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
	static let enoughAccuracy : CLLocationAccuracy = 50
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var locationManager = Model.shared.locationDataManager
	@StateObject var nearestStopViewModel : NearestStopViewModel = NearestStopViewModel(
		.loadingNearbyStops(
			Model.shared.locationDataManager.location ?? .init()
		)
	)
	@State var nearestStops : [StopWithDistance] = []
	@State var selectedStop : StopWithDistance?
	@State var departures : [LegViewData]?
	
	let timerForNearbyStopsRequest = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
	let timerForRequestStopDetails = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
	var body: some View {
			VStack(alignment: .leading,spacing: 0) {
				header()
				Color.chewFillAccent.opacity(0.5)
					.clipShape(.rect(cornerRadius: 8))
					.frame(maxWidth: .infinity,minHeight: 170, maxHeight: 170)
					.overlay { content() }
			}
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
						nearestStops = Self.updateDistanceToStops(
							from: coord,
							stops: state.data.stops
						)
					}
				}
			})
			.onReceive(timerForNearbyStopsRequest, perform: { _ in
				if let coord = locationManager.location {
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
								stop: stop.stop
							)
						}
						nearestStops = Self.updateDistanceToStops(
							from: cl2,
							stops: nearestStops.map{$0.stop}
						)
					}
				}
			})
	}
	
	@ViewBuilder private func content() -> some View {
		switch locationManager.authorizationStatus {
		case .notDetermined,.none:
			HStack {
				ProgressView()
				Text(
					"Determining location",
					comment: "NSV: location notDetermined"
				)
			}
			.chewTextSize(.big)
			.foregroundStyle(.secondary)
		case .restricted,.denied:
			ErrorView(
				viewType: .error,
				msg: Text(
					"We need location to find nearby stops",
					comment: "NSV: location denied"
				),
				size: .big,
				action: {
					TopBarAlertViewModel.AlertType.userLocationError.infoAction?()
				}
			)
		default:
			switch locationManager.accuracyAuthorization {
			case .fullAccuracy:
				VStack(spacing: 0) {
					if let stop = selectedStop {
						VStack(alignment: .leading, spacing: 0) {
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
								ScrollView(showsIndicators: false) {
									VStack(alignment: .leading, spacing: 0) {
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
							}
							Spacer()
						}
						.transition(.move(edge: .trailing))
					} else {
						if !nearestStops.isEmpty {
							ScrollView(showsIndicators: false) {
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
										})
									}
								}
								.transition(.move(edge: .leading))
							}
						}
					}
				}
				.animation(.easeInOut, value: self.nearestStops)
				.onAppear {
					if let coord = locationManager.location {
						nearestStopViewModel.send(
							event: .didDragMap(coord)
						)
					}
					locationManager.startUpdatingLocationAndHeading()
				}
				.onDisappear {
					locationManager.stopUpdatingLocationAndHeading()
				}
				.padding(5)
			default:
				ErrorView(
					viewType: .error,
					msg: Text(
						"Precise location accuracy is needed to find nearby stops",
						comment: "NSV: location precise accuracy not allowed"
					),
					size: .big,
					action: {
						TopBarAlertViewModel.AlertType.userLocationError.infoAction?()
					}
				)
			}
		}
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
}


extension NearestStopView {
	private static func updateDistanceToStops(
		from : CLLocationCoordinate2D,
		stops: [Stop]
	) -> [StopWithDistance] {
		let location = CLLocation(
			latitude: from.latitude,
			longitude: from.longitude
		)
		return stops
			.map { stop in
				updateDistanceToStop(from: from, stop: stop)
			}
			.sorted(by: {$0.distance ?? 0 < $1.distance ?? 0})
	}
	private static func updateDistanceToStop(
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
