//
//  JourneyDetails.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import SwiftUI
import MapKit

extension JourneyDetailsView {
	@ViewBuilder func follow() -> some View {
		Button(
			action: {
				switch viewModel.state.status {
				default:
					viewModel.send(event: .didTapSubscribingButton(
						id: viewModel.state.data.id,
						ref: viewModel.state.data.viewData.refreshToken,
						journeyDetailsViewModel: viewModel
					))
				}
			},
			label: {
				Group {
					switch viewModel.state.status {
					case .changingSubscribingState:
						ProgressView()
					default:
						let contains = Model.shared.journeyFollowVM.state.journeys.contains(where: {$0.id == viewModel.state.data.id})
						Image(.bookmark)
							.symbolVariant(contains ? .fill : .none )
					}
				}
				.frame(width: 15,height: 15)
				.padding(5)
			}
		)
	}
}


extension JourneyDetailsView {
	func toolbar() -> some View {
		HStack {
			Button {
				JourneyViewData
					.showOnMapOption
					.action(viewModel.state.data.viewData)
			} label: {
				ChooSFSymbols.map.view
			}
			if #available(iOS 17.0, *) {
				follow()
					.popoverTip(ChooTips.followJourney, arrowEdge: .bottom)
			} else {
				follow()
			}
			Button(
				action: {
					switch viewModel.state.status {
					case .loading, .loadingIfNeeded:
						viewModel.send(event: .didCancelToLoadData)
					case .loadedJourneyData, .changingSubscribingState:
						viewModel.send(event: .didTapReloadButton(
							id: viewModel.state.data.id,
							ref: viewModel.state.data.viewData.refreshToken
						))
					case .error(let error):
						Model.shared.alertVM.send(
							event: .didRequestShow(.action(
								action: {
									viewModel.send(event: .didTapReloadButton(
										id: viewModel.state.data.id,
										ref: viewModel.state.data.viewData.refreshToken
									))
								},
								description: error.localizedDescription,
								actionDescription: NSLocalizedString(
									"Try repeat",
									comment: "JDV: reload error: action description"
								),
								id: .init()
							))
						)
					}
				},
				label: {
					Group {
						switch viewModel.state.status {
						case .loading, .loadingIfNeeded:
							ProgressView()
						case .loadedJourneyData,
								.changingSubscribingState:
							Image(.arrowClockwise)
						case .error:
							Image(.exclamationmarkCircle)
						}
					}
					.frame(width: 15,height: 15)
					.padding(5)
				}
			)
		}
	}
}
