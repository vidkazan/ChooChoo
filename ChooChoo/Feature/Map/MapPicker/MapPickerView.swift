//
//  MapPickerView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 12.02.24.
//

import Foundation
import SwiftUI
import MapKit


struct MapPickerView: View {
	let type : LocationDirectionType
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var vm : MapPickerViewModel
	@ObservedObject var tipVM : AppSettingsViewModel = Model.shared.appSettingsVM
	@State private var mapCenterCoords: CLLocationCoordinate2D
	
	var body: some View {
		MapPickerUIView(vm: vm,mapCenterCoords: mapCenterCoords)
			.overlay(alignment: .topLeading) { overlay }
			.overlay(alignment: .bottomLeading) { selectedStop }
			.cornerRadius(10)
			.padding(5)
	}
}

extension MapPickerView {
	init(
		vm : MapPickerViewModel,
		initialCoords: CLLocationCoordinate2D,
		type : LocationDirectionType
	) {
		self.vm = vm
		self.type = type
		self.mapCenterCoords = initialCoords
	}
}

extension MapPickerView {
	func chooseBtn(stop : Stop) -> some View {
		Button(action: {
			switch type {
			case .departure:
				chewVM.send(event: .didUpdateSearchData(dep: .location(stop)))
			case .arrival:
				chewVM.send(event: .didUpdateSearchData(arr: .location(stop)))
			}
			Model.shared.sheetVM.send(event: .didRequestHide)
		}, label: {
			Text(
				"Choose",
				 comment: "mapPickerView: button to choose stop"
			)
				.padding(5)
				.badgeBackgroundStyle(.blue)
				.chewTextSize(.big)
				.foregroundColor(.white)
		})
	}
	
	var selectedStop : some View {
		Group {
			if let stop  = vm.state.data.selectedStop {
				VStack {
					HStack {
						StopListCell(
							stop: stop,
							isMultiline: true
						)
						Spacer()
						if case .loadingStopDetails = vm.state.status {
							ProgressView()
								.padding(3)
						}
						chooseBtn(stop: stop)
					}
					switch vm.state.status {
					case .idle, .loadingNearbyStops,.loadingStopDetails:
						if let trips = vm.state.data.selectedStopTrips, !trips.isEmpty {
							VStack {
								ScrollView {
									VStack(spacing: 2) {
										ForEach(trips, id: \.id) { trip in
											DeparturesListCellView(trip: trip)
										}
									}
								}
							}
							.frame(maxWidth: .infinity,minHeight: 0,maxHeight: 120)
						}
					case .error(let chewError):
						Text(chewError.localizedDescription)
					case .submitting:
						EmptyView()
					}
				}
				.padding(5)
				.badgeBackgroundStyle(.accent)
			}
		}
		.padding(5)
	}
	
	var overlay : some View {
		Group {
			VStack {
				switch vm.state.status {
				case .loadingNearbyStops:
					ProgressView()
				case .error(let chewError):
					ErrorView(
						viewType: .error,
						msg: Text(verbatim: chewError.localizedDescription),
						size: .medium,
						action: nil
					)
					.padding(5)
					.foregroundStyle(.secondary)
					.badgeBackgroundStyle(.accent)
				case .submitting,.idle,.loadingStopDetails:
					EmptyView()
				}
				if tipVM.state.settings.showTip(tip: .mapPickerLocationPick) {
					ChooTip.mapPickerLocationPick(onClose: {
						tipVM.send(event: .didShowTip(tip: .mapPickerLocationPick))
					}).tipLabel
				}
			}
		}
		.padding(5)
	}
}

#if DEBUG
struct MapPicker_Previews: PreviewProvider {
	static var previews: some View {
		MapPickerView(
			vm: .init(.idle),
			initialCoords: .init(latitude: 51.2, longitude: 6.68),
			type: .departure
		)
	}
}
#endif
