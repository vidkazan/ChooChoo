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
import OSLog

struct NearestStopView : View {
	static let enoughAccuracy : CLLocationAccuracy = 30
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var locationManager = Model.shared.locationDataManager
	@StateObject var nearestStopViewModel : NearestStopViewModel = NearestStopViewModel(
		.loadingNearbyStops(
			Model.shared.locationDataManager.location ?? .init()
		)
	)
	
	@State var nearestStops : [StopWithDistance] = []
	@State var selectedStop : StopWithDistance?
	@State var departuresTypes = Set<LineType>()
	@State var departures : [LegViewData]?
	@State var previousLocation = CLLocation()
	@State var filteredLineType : LineType?
	
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
			.onChange(of: selectedStop, perform: { stop in
				if stop == nil {
					filteredLineType = nil
				}
			})
			.onReceive(nearestStopViewModel.$state, perform: { state in
				departures = state.data.selectedStopTrips
				if let departures = departures {
					departuresTypes.removeAll()
					departures.forEach {
						departuresTypes.insert($0.lineViewData.type)
					}
				}
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
			.onReceive(timerForRequestStopDetails, perform: { _ in
				if let stop = selectedStop {
					self.nearestStopViewModel.send(
						event: .didRequestReloadStopDepartures(stop.stop)
					)
				}
				Task {
					if let loc = locationManager.location {
						updateNearbyStopsIfNeeded(newLocation: loc)
					}
				}
			})
			.onReceive(locationManager.$location, perform: { location in
				Task {
					if let loc = locationManager.location {
						updateNearbyStopsIfNeeded(newLocation: loc)
						if let stop = selectedStop {
							selectedStop = Self.updateDistanceToStop(
								from: loc.coordinate,
								stop: stop.stop
							)
						}
						nearestStops = Self.updateDistanceToStops(
							from: loc.coordinate,
							stops: nearestStops.map{$0.stop}
						)
					}
				}
			})
	}

	private func updateNearbyStopsIfNeeded(newLocation : CLLocation) {
		let previousLocationCoords = previousLocation.coordinate
		let distance = newLocation.distance(previousLocationCoords)
		let targetDistance = targetDistance(
			accuracy: newLocation.horizontalAccuracy,
			distance: distance
		)
		if newLocation.distance(previousLocationCoords) > targetDistance {
			nearestStopViewModel.send(
				event: .didDragMap(newLocation)
			)
			previousLocation = newLocation
		}
	}
	private func targetDistance(accuracy : CLLocationAccuracy, distance : CLLocationDistance) -> CLLocationDistance {
		let targetDistance = CLLocationDistance(500)
		if accuracy > targetDistance * 2  {
			return accuracy / 2
		}
		return targetDistance
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
										ForEach(
											trips
												.filter {
													if let filteredLineType = filteredLineType {
														return filteredLineType == $0.lineViewData.type
													}
													return true
												},
											id: \.hashValue
										) { trip in
											Button(action: {
												Model.shared.sheetVM.send(
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
										nearestStops,id: \.hashValue
									) { stop in
										Button(
											action: {
												nearestStopViewModel.send(event: .didTapStopOnMap(stop.stop))
											},
											label: {
												stopWithDistance(stop: stop)
											}
										)
									}
								}
								.transition(.move(edge: .leading))
							}
							.animation(.easeInOut, value: self.nearestStops)
						} else {
							ErrorView(viewType: .alert, msg: Text("No stops found",comment: "NSV: nearest stops: emptyState"), action: nil)
						}
					}
				}
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
