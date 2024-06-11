//
//  JourneyCell.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 09.09.23.
//

import Foundation
import SwiftUI

struct JourneyCell: View {
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var appSettingsVM : AppSettingsViewModel = Model.shared.appSettingsVM
	let journey : JourneyViewData
	let stops : DepartureArrivalPairStop
	let isPlaceholder : Bool
	
	init(journey: JourneyViewData,stops : DepartureArrivalPairStop, isPlaceholder : Bool = false) {
		self.journey = journey
		self.stops = stops
		self.isPlaceholder = isPlaceholder
	}
	var body: some View {
		VStack(spacing: 0) {
			NavigationLink(destination: {
				let vm = Model.shared.journeyDetailViewModel(
					followId: Self.followID(journey: journey),
					 for: journey.refreshToken,
					 viewdata: journey,
					 stops: stops,
					 chewVM: chewVM
				)
				NavigationLazyView(
					JourneyDetailsView(journeyDetailsViewModel: vm)
				)
			}, label: {
				VStack(spacing: 0) {
					JourneyHeaderView(journey: journey)
					LegsView(
						journey : journey,
						mode : appSettingsVM.state.settings.legViewMode
					)
					.padding(.horizontal,7)
				}
			})
			HStack(alignment: .center) {
				if let pl = journey.legs.first?.legStopsViewData.first?.platforms.departure {
					PlatformView(
						isShowingPlatormWord: false,
						platform: pl
					)
				}
				if let name = journey.legs.first?.legStopsViewData.first?.name {
					Text(verbatim: name)
						.chewTextSize(.medium)
						.tint(.primary)
				}
				Spacer()
				BadgesView(badges: journey.badges)
				Button(action:{ JourneyViewData.showOnMapOption.action(journey)}, label: {
					Image(systemName: JourneyViewData.showOnMapOption.icon)
						.chewTextSize(.medium)
						.padding(5)
						.badgeBackgroundStyle(.primary)
						.foregroundColor(.primary)
				})
			}
			.padding(7)
		}
		.background(Color.chewFillAccent.opacity(0.5))
		.overlay {
			if journey.isReachable == false {
				Color.primary.opacity(0.4)
			}
		}
		.redacted(reason: isPlaceholder ? .placeholder : [])
		.cornerRadius(10)
		.contextMenu { menu }
	}
	
	static func followID(journey : JourneyViewData) -> Int64 {
		let journeys = Model.shared.journeyFollowVM.state.journeys
		guard let followID = journeys.first(where: {
			$0.journeyViewData.refreshToken == journey.refreshToken
		})?.id else {
			return Int64(journey.refreshToken.hashValue)
		}
		return followID
		
	}
}

extension JourneyCell {
	var menu : some View {
		Group {
			if !journey.options.isEmpty {
				ForEach(journey.options, id:\.text) { option in
					Button(action: {
						option.action(journey)
					}, label: {
						Label(title: {
							Text(verbatim: option.text)
						}, icon: {
							Image(systemName: option.icon)
						})
					})
				}
			}
		}
	}
}

#if DEBUG
@available(iOS 16.0, *)
struct JourneyCellPreview: PreviewProvider {
	
	static var previews: some View {
		let mocks = [
			Mock.journeys.journeyNeussWolfsburg2.decodedData
//			Mock.journeys.journeyNeussWolfsburgFirstCancelled.decodedData
		]
		VStack {
			Spacer()
			ForEach(mocks,id: \.?.realtimeDataUpdatedAt){ mock in
				if let mock = mock {
					let viewData = mock.journey.journeyViewData(
					   depStop: nil,
					   arrStop: nil,
					   realtimeDataUpdatedAt: 0,
					   settings: .init()
				   )

					JourneyCell(
						journey: viewData!,
						stops: .init(departure: .init(coordinates: .init(), type: .stop, stopDTO: nil), arrival: .init(coordinates: .init(), type: .stop, stopDTO: nil))
					)
					.environmentObject(ChewViewModel(
						referenceDate: .specificDate(
							(viewData?.time.timestamp.departure.actual ?? 0) + 5000
						),
						coreDataStore: .preview
					))
					.background(.gray.opacity(0.2))
					.cornerRadius(10)
				}
			}
			Spacer()
		}
		.padding()
	}
}
#endif
