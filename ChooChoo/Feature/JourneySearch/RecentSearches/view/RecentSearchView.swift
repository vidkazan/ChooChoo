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
	@ObservedObject var recentSearchesVM : RecentSearchesViewModel
	@State var searches : [RecentSearchesViewModel.RecentSearch] = []
	
	init(recentSearchesVM: RecentSearchesViewModel = Model.shared.recentSearchesVM) {
		self.recentSearchesVM = recentSearchesVM
	}
	
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

private func geenrateRecentSearches(count : Int) -> [RecentSearchesViewModel.RecentSearch] {
	var res = [RecentSearchesViewModel.RecentSearch]()
	for _ in 0..<count {
		let nums = (String(Int.random(in: 0...1000)),String(Int.random(in: 0...1000)))
		res.append(.init(
			depStop: Stop(
			 coordinates: .init(latitude: 0, longitude: 0),
			 type: .stop,
			 stopDTO: .init(
				type: nil,
				id: nums.0,
				name: nums.0,
				address: nil,
				location: nil,
				latitude: nil,
				longitude: nil,
				poi: Bool.random(),
				products: .init(
					regional: Bool.random(),
					suburban: Bool.random(),
					bus: Bool.random(),
					subway: Bool.random(),
					tram: Bool.random()
				),
				distance: nil,
				station: nil
			 )
		 ),
		 arrStop: Stop(
			coordinates: .init(latitude: 0, longitude: 0),
			type: .stop,
			stopDTO: .init(
				type: nil,
			   id: nums.1,
			   name: nums.1,
			   address: nil,
			   location: nil,
			   latitude: nil,
			   longitude: nil,
				poi: Bool.random(),
				products: .init(
					nationalExpress: Bool.random(),
					national: Bool.random(),
					regionalExpress: Bool.random(),
					regional: Bool.random(),
					suburban: Bool.random(),
					subway: Bool.random()
				),
				distance: nil,
			   station: nil
			)
		 ),
			searchTS: Date.now.timeIntervalSince1970
	 ))
	}
	return res
}


#if DEBUG
struct RecentSearchView_Previews: PreviewProvider {
	static var previews: some View {
		let chewVM = ChewViewModel(coreDataStore: .preview)
		let recentSearchViewModel = RecentSearchesViewModel(searches: geenrateRecentSearches(count: 0),coreDataStore: .preview)
		VStack {
			RecentSearchesView(recentSearchesVM: recentSearchViewModel)
				.environmentObject(chewVM)
			Button("Add", action: {
				recentSearchViewModel.send(
					event: .didTapEdit(action: .adding, search: geenrateRecentSearches(count: 1).first)
				)
			})
			.buttonStyle(.bordered)
		}
		.onAppear {
			chewVM.send(event: .didStartViewAppear)
			recentSearchViewModel.send(
				event: .didTapEdit(action: .adding, search: geenrateRecentSearches(count: 1).first)
			)
		}
	}
}
#endif
