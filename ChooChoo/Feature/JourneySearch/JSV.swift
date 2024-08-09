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
	@Namespace var journeySearchViewNamespace
	@EnvironmentObject var chewViewModel : ChewViewModel
	@ObservedObject var searchStopsVM = Model.shared.searchStopsVM
	@ObservedObject var topAlertVM = Model.shared.topBarAlertVM
	@ObservedObject var locationManager : ChewLocationDataManager = Model.shared.locationDataManager

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
				if #available(iOS 17.0, *) {
					TipView(ChooTips.searchTip)
				}
				
				VStack {
					SearchStopsView()
					TimeAndSettingsView()
				}
				BottomView()
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
				ToolbarItem(
					placement: .topBarLeading,
					content: {
						if topAlertVM.state.alerts.contains(.offline) {
							BadgeView(.offlineMode)
								.badgeBackgroundStyle(.blue)
						} else if topAlertVM.state.alerts.contains(.apiUnavailable) {
							BadgeView(.apiUnavaiable)
								.badgeBackgroundStyle(.primary)
						}
					}
				)
				ToolbarItem(placement: .topBarTrailing, content: {
					Button(action: {
						Model.shared.sheetVM.send(event: .didRequestShow(.appSettings))
					}, label: {
						ChooSFSymbols.gearshape.view
							.tint(.secondary)
					})
					.frame(maxWidth: 40,maxHeight: 40)
				})
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

#if DEBUG
struct JSV_Previews: PreviewProvider {
	static var previews: some View {
		let chewVM = ChewViewModel(
			coreDataStore: .preview
		)
		JourneySearchView()
			.onAppear(perform: {
				chewVM.send(event: .didStartViewAppear)
			})
		.environmentObject(chewVM)
	}
}
#endif
