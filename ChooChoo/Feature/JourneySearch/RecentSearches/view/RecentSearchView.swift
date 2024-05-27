//
//  FavouriteRidesView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.10.23.
//

import Foundation
import SwiftUI
import CoreLocation

struct RecentSearchesView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var recentSearchesVM : RecentSearchesViewModel = Model.shared.recentSearchesVM
	@State var searches : [RecentSearchesViewModel.RecentSearch] = []
	var body: some View {
		Group {
			if !recentSearchesVM.state.searches.isEmpty {
				VStack(alignment: .leading,spacing: 2) {
					Text(
						"Recents",
						comment: "RecentSearchesView: view name"
					)
					.chewTextSize(.big)
					.offset(x: 10)
					.foregroundColor(.secondary)
					ScrollView(.horizontal,showsIndicators: false) {
						HStack {
							ForEach(searches,id: \.searchTS) { locations in
								RecentSearchCell(
									send: recentSearchesVM.send,
									locations:locations.stops
								)
							}
						}
					}
				}
			}
		}
		.onReceive(recentSearchesVM.$state, perform: { state in
			Task {
				self.searches = Array(state.searches
					.sorted(by: {$0.searchTS > $1.searchTS}).prefix(5))
			}
		})
	}
}

