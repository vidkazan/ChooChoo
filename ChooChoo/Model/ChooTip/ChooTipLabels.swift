//
//  ChooTip.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 24.04.24.
//

import Foundation
import SwiftUI

extension ChooTip {
	struct Labels {
		enum AnimCase : String,CaseIterable {
			case center0
			case right
			case center1
			case left
			
			var leftCellsWidth : CGFloat {
				switch self {
				case .center0:
					return 0
				case .right:
					return 40
				case .center1:
					return 0
				case .left:
					return 0
				}
			}
			var rightCellsWidth : CGFloat {
				switch self {
				case .center0:
					return 0
				case .right:
					return 0
				case .center1:
					return 0
				case .left:
					return 40
				}
			}
		}
		struct SwipeActionsTip : View {
			@Environment(\.colorScheme) var colorScheme
			@State var anim : AnimCase = .center0
			let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
			var body: some View {
				HStack(spacing: 0) {
					Group {
						Color.chewFillGreenSecondary
						Color.chewFillYellowPrimary
					}
					.frame(width: anim.leftCellsWidth)
					Rectangle()
						.fill(
							colorScheme == .dark ? Color.chewFillAccent : .white
						)
						.overlay{
							Text("Swipe for action",comment: "SwipeActionsTip")
								.chewTextSize(.medium)
								.foregroundStyle(.primary.opacity(0.8))
						}
					Color.chewFillRedPrimary
						.frame(width: anim.rightCellsWidth)
				}
				.frame(height: 40)
				.clipShape(.rect(cornerRadius: 10))
				.onReceive(timer, perform: { _ in
					withAnimation(.spring, {
						anim = anim.next()
					})
				})
			}
		}
		
		struct JourneySettingsFilterDisclaimer : View {
			var body: some View {
				HStack {
					Label(
						title: {
							Text(
								"Current settings could reduce your search results",
								comment: "settingsView: warning"
							)
								.foregroundStyle(.secondary)
								.font(.system(.footnote))
						},
						icon: {
							JourneySettings.IconBadge.redDot.view
						}
					)
					Spacer()
					Button(action: {
						Model.shared.appSettingsVM.send(event: .didShowTip(tip: .journeySettingsFilterDisclaimer))
					}, label: {
						Image(.xmarkCircle)
							.chewTextSize(.big)
							.tint(.secondary)
					})
				}
			}
		}
		
		struct SunEventsTipLabel: View {
			let onClose : () -> ()
			let journey : JourneyViewData?
			var body: some View {
				Button(action: {
					Model.shared.sheetVM.send(
						event: .didRequestShow(
							.tip(
								.sunEvents(
									onClose: onClose,
									journey: journey
								)
							)
						)
					)
				}, label : {
					HStack {
						Label(
							title: {
								Text("What does this colorful line mean?", comment: "jlv: header info: sunevents")
									.chewTextSize(.medium)
							},
							icon: {
								ChooSFSymbols.infoCircle.view
									.padding(.leading,10)
							}
						)
						.tint(.primary)
						Spacer()
						Button(action: {
							onClose()
						}, label: {
							ChooSFSymbols.xmarkCircle.view
								.chewTextSize(.big)
								.tint(.gray)
						})
						.frame(width: 40, height: 40)
					}
					.padding(5)
					.frame(height: 40)
					.background {
						LinearGradient(
							stops: journey?
								.sunEventsGradientStops
								.map {
									.init(
										color: $0.color.opacity(0.7),
										location: $0.location
									)
								} ?? .init(),
							startPoint: .leading,
							endPoint: .trailing
						)
					}
					.clipShape(.rect(cornerRadius: 8))
				})
			}
		}
	}
}


struct SunEventsTipView : View {
	let mode : AppSettings.LegViewMode
	let mock = Mock
		.journeys
		.journeySyltWien
		.decodedData?
		.journey
		.journeyViewData(
			depStop: nil,
			arrStop: nil,
			realtimeDataUpdatedAt: 0,
			settings: .init()
	)
	var body: some View {
		if let mock = mock {
			VStack(alignment: .leading) {
				Text("**Yellow** color shows **daylight**,",comment: "SunEventsTipView")
				Text("**Blue** color - **moonlight**",comment: "SunEventsTipView")
				LegsView(
					journey: mock,
					mode: mode,
					showLabels: false,
					showLegs: false
				)
				.overlay {
					HStack {
						ChooSFSymbols.sunMaxFill.view.chewTextSize(.medium)
							.padding(.leading,20)
						Spacer()
						ChooSFSymbols.moonStars.view.chewTextSize(.medium)
						Spacer()
						ChooSFSymbols.sunMaxFill.view.chewTextSize(.medium)
							.padding(.trailing,10)
					}
					.foregroundStyle(.primary)
				}
			}
			.padding(10)
			.badgeBackgroundStyle(.secondary)
			.padding(10)
		}
	}
}
