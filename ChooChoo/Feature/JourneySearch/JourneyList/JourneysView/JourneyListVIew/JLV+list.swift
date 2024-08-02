//
//  JourneyView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.08.23.
//

import SwiftUI

extension JourneyListView {
	func list() -> some View {
		return ScrollViewReader { val in
			ScrollView {
				LazyVStack(spacing: 10) {
					if appSettingsViewModel.state.settings.showTip(tip: .sunEventsTip) {
						ChooTip.sunEvents(
							onClose: {
								appSettingsViewModel.send(event: .didShowTip(tip: .sunEventsTip))
							},
							journey: journeyViewModel.state.data.journeys.first
						)
						.tipLabel
					}
					ForEach(journeyViewModel.state.data.journeys,id: \.id) { journey in
						JourneyCell(
							journey: journey,
							stops: journeyViewModel.state.data.stops.chooDepartureArrivalPairStop()
						)
					}
					.id(1)
					switch journeyViewModel.state.status {
					case .journeysLoaded, .failedToLoadEarlierRef:
						if journeyViewModel.state.data.laterRef != nil {
							ProgressView()
								.onAppear{
									journeyViewModel.send(event: .onLaterRef)
								}
								.frame(maxHeight: 100)
						} else {
							Label(
								title: {
									Text("change the time of your search to find later connections", comment: "JourneyListView: error: laterRef is nil")
								},
								icon: {
									Image(systemName: "exclamationmark.circle")
								}
							)
								.chewTextSize(.medium)
						}
					case .loadingRef(let type):
						if type == .laterRef {
							ProgressView()
								.frame(maxHeight: 100)
						}
					case .failedToLoadLaterRef:
						Label(
							title: {
								Text("error: try reload", comment: "JourneyListView: error: failed to load laterRef rides")
							},
							icon: {
								Image(systemName: "exclamationmark.circle")
							}
						)
						.onTapGesture {
							journeyViewModel.send(event: .onLaterRef)
						}
					case .loadingJourneyList, .failedToLoadJourneyList:
						Image(systemName: "exclamationmark.circle.fill")
					}
				}
				.cornerRadius(10)
			}
			.refreshable {
				journeyViewModel.send(event: .onReloadJourneyList)
			}
//			.onAppear {
//				if firstAppear == true {
//					val.scrollTo(1, anchor: .top)
//					firstAppear.toggle()
//				}
//			}
		}
	}
}
