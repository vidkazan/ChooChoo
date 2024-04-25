//
//  BottomView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 21.01.24.slo
//

import Foundation
import SwiftUI

struct BottomView: View {
	@ObservedObject var searchStopsVM = Model.shared.searchStopsVM
	@EnvironmentObject var chewViewModel : ChewViewModel
	@State var state = ChewViewModel.State()
	var body: some View {
		Group {
			switch state.status {
			case let .journeys(stops):
				JourneyListView(
					stops: stops,
					date: state.data.date,
					settings: state.data.journeySettings
				)
			case .idle:
				ScrollView {
					RecentSearchesView()
					NearestStopView()
				}
			default:
				Spacer()
			}
		}
		.onReceive(chewViewModel.$state, perform: { new in
			state = new
		})
	}
}
