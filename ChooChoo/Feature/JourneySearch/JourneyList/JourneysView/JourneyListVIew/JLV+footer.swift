//
//  JourneyView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.08.23.
//

import SwiftUI

extension JourneyListView {
	@ViewBuilder func footer() -> some View {
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
            if case .laterRef(let string) = type {
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
}
