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
		VStack(spacing: 0) {
			#if DEBUG
			if let name = GitBranch.current?.branchName {
				Text(verbatim: name)
					.foregroundStyle(.secondary)
					.padding(2)
					.chewTextSize(.medium)
					.badgeBackgroundStyle(.secondary)
					.padding(1)
			}
			#endif
			VStack(spacing: 5) {
				if #available(iOS 17.0, *) {
					TipView(ChooTips.searchTip)
				}
				SearchStopsView()
				TimeAndSettingsView()
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
		Color.transport.tramRed.opacity(0.4),
		Color.transport.tramRed.opacity(0.2)
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
