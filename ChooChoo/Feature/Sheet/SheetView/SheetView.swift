//
//  SheetView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 07.02.24.
//

import Foundation
import SwiftUI
import MapKit

struct SheetView : View {
	@EnvironmentObject var chewViewModel : ChewViewModel
	@ObservedObject var sheetVM : SheetViewModel = Model.shared.sheetVM
	let closeSheet : ()->Void
	var body: some View {
		switch sheetVM.state.status {
		case .error(let error):
			EmptyView()
				.onAppear {
					Model.shared.topBarAlertVM.send(
						event: .didAdd([
							.generic(msg: error.localizedDescription)
						])
					)
				}
		case .loading(let type):
			if #available(iOS 16.0, *) {
				NavigationStack {
					ProgressView()
				}
				.presentationDetents(Set(makePresentationDetent(chewDetents: type.detents)))
			} else {
				NavigationView {
					ProgressView()
				}
			}
		case let .showing(type, data):
			if #available(iOS 16.0, *) {
				NavigationStack {
					sheet(data: data, type: type)
				}
				.presentationDetents(Set(makePresentationDetent(chewDetents: type.detents)))
			} else {
				NavigationView {
					sheet(data: data, type: type)
				}
			}
		}
	}
}

private extension SheetView {
	@ViewBuilder func sheet(
		data : any SheetViewDataSource,
		type : SheetViewModel.SheetType
	) -> some View {
		SheetViewInner(
			data: data,
			type: type,
			closeSheet: closeSheet
		)
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle(type.description)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading, content: {
					Button(action: {
						closeSheet()
					}, label: {
						Text(
							"Close",
							 comment: "SheetView: toolbar: button name"
						)
					})
				})
			}
	}
}

struct SheetViewInner : View {
	@EnvironmentObject var chewViewModel : ChewViewModel
	let data : any SheetViewDataSource
	let type : SheetViewModel.SheetType
	let closeSheet : ()->Void
	var body: some View {
		switch type {
		case .alternatives(let journey):
			
		case .appSettings:
			AppSettingsView(appSetttingsVM: Model.shared.appSettingsVM)
		case .tip(let tipType):
			tipType.tipView
		case .journeySettings:
			SettingsView(
				settings: chewViewModel.state.data.journeySettings,
				closeSheet: closeSheet
			)
		case .date:
			DatePickerView(
				date: chewViewModel.state.data.date.date.date,
				time: chewViewModel.state.data.date.date.date,
				closeSheet: closeSheet
			)
		case .route:
			if let data = data as? RouteViewDataSource {
				RouteSheet(leg: data.leg)
			}
		case .mapDetails:
			if let data = data as? MapDetailsViewDataSource {
				MapDetailsView(
					mapRect: data.coordRegion,
					legs: data.mapLegDataList
				)
			}
		case .mapPicker(type: let type):
			let initialCoords = Model.shared.locationDataManager.location?.coordinate ?? .init(latitude: 52, longitude: 7)
			MapPickerView(
				vm : MapPickerViewModel(.loadingNearbyStops(MKCoordinateRegion(
					center: initialCoords,
					latitudinalMeters: 0.01,
					longitudinalMeters: 0.01))),
				initialCoords: initialCoords,
				type: type
			)
		case .none:
			EmptyView()
		case .onboarding:
			EmptyView()
		case .remark:
			if let data = data as? RemarksViewDataSource {
				RemarkSheet(remarks: data.remarks)
			}
		case .journeyDebug:
			if let data = data as? JourneyDebugViewDataSource {
				JourneyDebugView(legsDTO: data.legDTOs)
			}
		}
	}
}
