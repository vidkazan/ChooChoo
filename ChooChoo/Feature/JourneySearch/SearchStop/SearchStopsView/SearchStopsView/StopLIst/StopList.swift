//
//  SearchStopsView+StopList.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import CoreLocation
import Foundation
import SwiftUI

extension SearchStopsView {
	func stopList(type : LocationDirectionType) -> some View {
		VStack(alignment: .leading,spacing: 1) {
			recentStops(type: type,recentStops: recentStopsData)
			foundStop(type: type, stops: stops)
		}
		.onReceive(searchStopViewModel.$state, perform: { _ in
			update(type : type)
		})
		.onChange(of: type == .departure ? topText : bottomText, perform: { value in
			update(type : type)
		})
		.padding(.horizontal,5)
		.frame(maxWidth: .infinity,alignment: .leading)
	}
}

extension SearchStopsView {
	func update(type : LocationDirectionType) {
		Task {
			let recentStopsAll = searchStopViewModel.state.previousStops.filter { stop in
				return stop.name.hasPrefix(type == .departure ? topText : bottomText )
			}
			recentStopsData = Array(
				SearchStopsViewModel.sortedStopsByLocationWithDistance(stops: recentStopsAll).prefix(2)
			)
			
			stops = SearchStopsViewModel.sortedStopsByLocationWithDistance(stops: searchStopViewModel.state.stops)
			stops.removeAll(where: { stop in
				recentStopsData.contains(where: {$0.stop.name == stop.stop.name})
			})
		}
	}
}
