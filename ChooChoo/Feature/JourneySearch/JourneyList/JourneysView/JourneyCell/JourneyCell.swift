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
	let stops : ChooDepartureArrivalPairStop
	let mode : Self.JourneyCellMode
	
    init(journey: JourneyViewData,stops : ChooDepartureArrivalPairStop, mode : Self.JourneyCellMode = .base) {
		self.journey = journey
		self.stops = stops
		self.mode = mode
	}
	var body: some View {
		VStack(spacing: 0) {
			if let stops = stops.departureArrivalPairStop() {
				NavigationLink(destination: {
					let vm = Model.shared.journeyDetailViewModel(
						followId: Self.followID(journey: journey),
						journeyRef: journey.refreshToken,
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
				footer
			}
		}
		.background(self.mode == .base ? Color.chewFillAccent.opacity(0.5) : .clear)
		.overlay {
			if journey.isReachable == false {
				Color.primary.opacity(0.4)
			}
		}
		.cornerRadius(10)
		.contextMenu { menu }
	}
}

extension JourneyCell {
	enum JourneyCellMode {
		case alternatives
		case base
	}
}

extension JourneyCell {
	var footer : some View {
		HStack(alignment: .center) {
			if let firstLeg = journey.legs.first,
			   let searchFahrtId = stops.departure.leg?.tripId,
				firstLeg.tripId == searchFahrtId {
                HStack(spacing: 0) {
                    Text("continue with ", comment: "Alternatives: JourneyCell: footer: transport as a departure")
                        .padding(.horizontal,5)
                        .chewTextSize(.medium)
                    BadgeView(.lineNumberWithDirection(leg: firstLeg))
                }
                .badgeBackgroundStyle(.secondary)
			} else {
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
                if let zi = getTripIDMagicNumber(tripID: journey.legs.first?.tripId ?? "") {
                    BadgeView(.generic(msg: zi  ))
                }
			}
			Spacer()
			switch mode {
			case .base:
				BadgesView(badges: journey.badges)
//				Button(action:{
//					JourneyViewData.showOnMapOption.action(journey)
//				}, label: {
//					Image(systemName: JourneyViewData.showOnMapOption.icon)
//						.chewTextSize(.medium)
//						.padding(5)
//						.badgeBackgroundStyle(.primary)
//						.foregroundColor(.primary)
//				})
			case .alternatives:
				EmptyView()
			}
		}
		.padding(7)
	}
}

extension JourneyCell {
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

extension JourneyCell {
    func getTripIDMagicNumber(tripID : String) -> String? {
        let components = tripID.components(separatedBy: "#")
        if let ziIndex = components.firstIndex(of: "ZI") {
            let ziValue = components[ziIndex + 1]
            return ziValue
        }
        return nil
    }
}

//
//struct JourneyCellPreview: PreviewProvider {
//	static var previews: some View {
//		let mocks = [
//			Mock.journeys.journeyNeussWolfsburg.decodedData,
//			Mock.journeys.journeyNeussWolfsburgFirstCancelled.decodedData
//		]
//		VStack {
//			ForEach(mocks,id: \.?.realtimeDataUpdatedAt){ mock in
//				if let mock = mock,
//				   let viewData = mock.journey.journeyViewData(
//						depStop: .init(),
//						arrStop: .init(),
//						realtimeDataUpdatedAt: 0,
//						settings: .init()
//					) {
//					JourneyCell(journey: viewData,stops: .init(departure: .init(), arrival: .init()))
//						.environmentObject(ChewViewModel())
//				} else {
//					Text(verbatim: "error")
//				}
//			}
//		}
//		.padding()
//	}
//}
