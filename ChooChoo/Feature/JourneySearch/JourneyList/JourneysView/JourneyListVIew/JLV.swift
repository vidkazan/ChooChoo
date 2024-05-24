//
//  JourneyView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.08.23.
//

import SwiftUI


struct JourneyListView: View {
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var journeyViewModel : JourneyListViewModel
	@ObservedObject var appSettingsViewModel = Model.shared.appSettingsVM
	
	init(stops : DepartureArrivalPairStop, date: SearchStopsDate,settings : JourneySettings) {
		self.journeyViewModel = JourneyListViewModel(
			date: date,
			settings: settings,
			stops: stops
	   )
	}
	var body: some View {
		VStack {
			switch journeyViewModel.state.status {
			case .loadingJourneyList:
				loading()
			case .journeysLoaded,.loadingRef,.failedToLoadLaterRef,.failedToLoadEarlierRef:
				switch journeyViewModel.state.data.journeys.isEmpty {
				case true:
					notFound()
				case false:
					list()
				}
			case .failedToLoadJourneyList(let error):
				ErrorView(
					viewType: .error,
					msg: Text(verbatim: error.localizedDescription),
					reloadAction: {
						journeyViewModel.send(event: .onReloadJourneyList)
					}
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.animation(.easeInOut, value: appSettingsViewModel.state.settings)
	}
}

extension JourneyListView {
	func loading() -> some View {
		return Group {
			VStack {
				Spacer()
				ProgressView()
				Spacer()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
}

extension JourneyListView {
	func notFound() -> some View {
		return Group {
			ErrorView(
				viewType: .alert,
				msg: Text("Connections not found",comment: "JourneyListView: empty state"),
				action: nil
			)
				.padding(5)
				.frame(maxWidth: .infinity,alignment: .center)
			Spacer()
		}
	}
}

//
//struct JourneyListPreview : PreviewProvider {
//	static var previews: some View {
//		JourneyListView(
//			stops: .init(departure: .init(), arrival: .init()), 
//			date: .init(date: .now, mode: .departure),
//			settings: .init()
//		)
//			.environmentObject(ChewViewModel())
//	}
//}
