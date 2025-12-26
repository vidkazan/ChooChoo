//
//  JourneySearchView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.02.24.
//

import Foundation
import SwiftUI
import TipKit

struct JourneySearchView : View {
    let viewBuilder: NavigationViewBuilder
	@Namespace var journeySearchViewNamespace
	@EnvironmentObject var chewViewModel : ChewViewModel
	@ObservedObject var searchStopsVM = Model.shared.searchStopsVM
	@ObservedObject var locationManager : ChewLocationDataManager = Model.shared.locationDataManager
    @State var state = ChewViewModel.State()
	var body: some View {
			VStack(spacing: 5) {
				#if DEBUG
				Text(verbatim: GitBranch.shared.current?.branchName ?? "main")
						.foregroundStyle(.secondary)
						.padding(4)
						.chewTextSize(.medium)
						.badgeBackgroundStyle(.secondary)
						.padding(2)
				#endif
                TipView(ChooTips.searchTip)
				VStack {
					SearchStopsView()
					TimeAndSettingsView()
				}
                Group {
                    switch state.status {
                    case let .journeys(stops):
                        viewBuilder.createJourneyListView(
                            date: state.data.date,
                            settings: state.data.journeySettings,
                            stops: stops
                        )
                    case .idle:
                        ScrollView {
                            VStack {
                                RecentSearchesView()
                                viewBuilder.createNearestStopView()
                            }
                        }
                    default:
                        Spacer()
                    }
                }
                .onReceive(chewViewModel.$state, perform: { new in
                    state = new
                })
			}
			.contentShape(Rectangle())
			.padding(.horizontal,10)
			.background(alignment: .top, content: {
				gradient()
			})
			.background(Color.chewFillPrimary)
			.navigationTitle(
				Text(verbatim: Constants.navigationTitle)
			)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				JourneySearchToolbar(topBarAlertVM: Model.shared.topBarAlertVM)
			}
			.onReceive(locationManager.$location, perform: { loc in
				if
					case .loadingLocation = chewViewModel.state.status,
					let lat = loc?.coordinate.latitude,
					let long = loc?.coordinate.longitude {
					chewViewModel.send(event: .didReceiveLocationData(
						Stop(
							coordinates: Coordinate(
								latitude: lat,
								longitude: long),
							type: .location,
							stopDTO: nil
						)
					))
				}
			})
	}
}

extension JourneySearchView {
	struct JourneySearchToolbar: ToolbarContent {
		@ObservedObject var topBarAlertVM: TopBarAlertViewModel
		var body: some ToolbarContent {
			JourneySearchView.topBarLeadingToolbar(topBarAlertVM: topBarAlertVM)
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {
					Model.shared.sheetVM.send(event: .didRequestShow(.appSettings))
				}, label: {
					ChooSFSymbols.gearshape.view
						.tint(.secondary)
				})
				.frame(maxWidth: 40, maxHeight: 40)
			}
		}
	}

	static let colors : [Color] = {
		#if DEBUG
		debugColors
		#else
		releaseColors
		#endif
	}()
	static private let releaseColors = [
		Color.transport.uBlue.opacity(0.1),
		Color.transport.shipCyan.opacity(0.05)
	]
	static private let debugColors = [
		Color.transport.busMagenta.opacity(0.4),
		Color.transport.busMagenta.opacity(0.2)
	]
	@ViewBuilder func gradient() -> some View {
		ZStack {
			Rectangle().ignoresSafeArea(.all)
				.foregroundStyle(.clear)
				.background (
					.linearGradient(
						colors: Self.colors,
						startPoint: UnitPoint(x: 0.2, y: 0),
						endPoint: UnitPoint(x: 0.2, y: 0.4)
					)
				)
				.frame(maxWidth: .infinity, maxHeight: 170)
				.blur(radius: 50)
			Rectangle()
				.foregroundStyle(.clear)
				.background (
					.linearGradient(
						colors: [
							.transport.shipCyan.opacity(0.2),
							.transport.uBlue.opacity(0.1),
						],
						startPoint: UnitPoint(x: 0, y: 0),
						endPoint: UnitPoint(x: 1, y: 0))
				)
				.frame(maxWidth: .infinity, maxHeight: 170)
				.blur(radius: 50)
		}
	}
}

extension JourneySearchView {
	static func topBarLeadingToolbar(topBarAlertVM : TopBarAlertViewModel) -> some ToolbarContent {
		ToolbarItem(
			placement: .topBarLeading,
			content: {
				if topBarAlertVM.state.alerts.contains(.offline) {
					Button(action: {
						UIApplication.shared.open(URL(string: "http://captive.apple.com")!,options: [:], completionHandler: nil)
					}, label: {
						BadgeView(.offlineMode)
							.foregroundColor(.primary)
							.badgeBackgroundStyle(.blue)
					})
				} else if topBarAlertVM.state.alerts.contains(.apiUnavailable) {
					BadgeView(.apiUnavaiable)
						.badgeBackgroundStyle(.primary)
				}
			}
		)
	}
}


#if DEBUG
struct JSV_Previews: PreviewProvider {
	static var previews: some View {
		let chewVM = ChewViewModel(
			coreDataStore: .preview
		)
        JourneySearchView(viewBuilder: .init(container: AppContainerImpl.shared, router: Router()))
			.onAppear(perform: {
				chewVM.send(event: .didStartViewAppear)
			})
		.environmentObject(chewVM)
	}
}
#endif
