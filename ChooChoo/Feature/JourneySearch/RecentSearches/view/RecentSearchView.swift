//
//  FavouriteRidesView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.10.23.
//

import Foundation
import SwiftUI
import CoreLocation

struct DepartureArrivalPairStop : Hashable,Codable {
	let departure : Stop
	let arrival : Stop
	let id : String
	init(departure: Stop, arrival: Stop) {
		self.departure = departure
		self.arrival = arrival
		self.id = departure.name + arrival.name
	}
}

struct DepartureArrivalPair<T: Hashable & Codable> : Hashable, Codable {
	let departure : T
	let arrival : T
	init(departure: T, arrival: T) {
		self.departure = departure
		self.arrival = arrival
	}
}

extension DepartureArrivalPair {
	func encode() -> Data? {
		return try? JSONEncoder().encode(self)
	}
	static func decode(data: Data) -> Self? {
		return try? JSONDecoder().decode(Self.self, from: data)
	}
}



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

