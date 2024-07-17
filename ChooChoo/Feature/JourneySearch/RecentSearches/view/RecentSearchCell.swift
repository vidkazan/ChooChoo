//
//  FavouriteRideCell.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.10.23.
//

import Foundation
import SwiftUI

struct RecentSearchCell: View {
	@EnvironmentObject var chewVM : ChewViewModel
	let send : (RecentSearchesViewModel.Event) -> Void
	let locations : DepartureArrivalPairStop
	var body: some View {
		Button(action: {
			chewVM.send(
				event: .didUpdateSearchData(
					dep: ChewViewModel.TextFieldContent.location(locations.departure),
					arr: ChewViewModel.TextFieldContent.location(locations.arrival)
				)
			)
		}, label: {
			HStack(alignment: .top,spacing: 0) {
				VStack(alignment: .leading,spacing: 0) {
					StopListCell(stop: locations.departure)
						.frame(maxWidth: 250, alignment: .leading)
					StopListCell(stop: locations.arrival)
						.frame(maxWidth: 250,alignment: .leading)
				}
//				.frame(height: 100)
				CloseButton(action: {
					send(.didTapEdit(
						action: .deleting,
						search: RecentSearchesViewModel.RecentSearch(
							stops: locations,
							searchTS: Date.now.timeIntervalSince1970
						)
					))
				})
				.frame(width: 25,height: 25)
				.background(Color.chewFillAccent.opacity(0.3))
				.cornerRadius(20)
			}
		})
		.foregroundStyle(.primary)
		.padding(5)
		.background(Color.chewFillAccent.opacity(0.5))
		.clipShape(.rect(cornerRadius: 8))
	}
}
//
//struct RecentSearchesPreviews: PreviewProvider {
//	static var previews: some View {
//		let mock = Mock.trip.RE6NeussMinden.decodedData?.trip
//		RecentSearchesView(
//			recentSearchesVM: .init(
//				searches: [
//					.init(
//						depStop: mock?.stopovers?[23].stop?.stop() ?? .init(),
//						arrStop: mock?.destination?.stop() ?? .init(),
//						searchTS: 0
//					)
//				]
//			)
//		)
//		.padding()
//		.background(.chewFillTertiary)
//		.environmentObject(ChewViewModel(referenceDate: .now))
//	}
//}
