//
//  Settings.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation
import SwiftUI

struct AppSettings : Hashable, Codable {
	let debugSettings : ChewDebugSettings
	let legViewMode : LegViewMode
	let tipsToShow : Set<ChooTipType>
	init(debugSettings : ChewDebugSettings,
		legViewMode : LegViewMode,
		tips : Set<ChooTipType>
	) {
		self.legViewMode = legViewMode
		self.tipsToShow = tips
		self.debugSettings = debugSettings
	}
	
	init(oldSettings : Self,
		debugSettings : ChewDebugSettings? = nil,
		legViewMode : LegViewMode? = nil,
		 tips : Set<ChooTipType>? = nil
	) {
		self.legViewMode = legViewMode ?? oldSettings.legViewMode
		self.tipsToShow = tips ?? oldSettings.tipsToShow
		self.debugSettings = debugSettings ?? oldSettings.debugSettings
	}
	
	init() {
		self.legViewMode = .sunEvents
		self.tipsToShow = Set(ChooTipType.allCases)
		self.debugSettings = ChewDebugSettings(prettyJSON: false, alternativeSearchPage: false)
	}
}

extension AppSettings {
	struct ChewDebugSettings: Hashable, Codable {
		let prettyJSON : Bool
		let alternativeSearchPage : Bool
	}
	
	enum LegViewMode : Int16, Hashable,CaseIterable, Codable {
		case sunEvents
		case colorfulLegs
		case all
		
		var description : [String] {
			switch self {
			case .sunEvents:
				return [NSLocalizedString("sunlight / moonlight color", comment: "AppSettings: LegViewMode: description")]
			case .colorfulLegs:
				return [NSLocalizedString("transport type color", comment: "AppSettings: LegViewMode: description")]
			case .all:
				return
					Array(
						Self.colorfulLegs.description
						+
						Self.sunEvents.description
					)
			}
		}
		
		var showSunEvents : Bool {
			self != .colorfulLegs
		}
		var showColorfulLegs : Bool {
			self != .sunEvents
		}
	}
	
	enum ChooTipType : String ,Hashable, CaseIterable,Codable {
		case journeySettingsFilterDisclaimer
		case followJourney
		case sunEventsTip
		case swipeActions
	}
	enum ChooTip : Hashable {
		static func == (lhs: ChooTip, rhs: ChooTip) -> Bool {
			lhs.description == rhs.description
		}
		func hash(into hasher: inout Hasher) {
			hasher.combine(description)
		}
		case swipeActions
		case followJourney
		case journeySettingsFilterDisclaimer
		case sunEvents(onClose: () -> (), journey: JourneyViewData?)
		
		var description  : String {
			switch self {
			case .swipeActions:
				return "swipe actions"
			case .journeySettingsFilterDisclaimer:
				return "journeySettingsFilterDisclaimer"
			case .followJourney:
				return "followJourney"
			case .sunEvents:
				return "sunEvents"
			}
		}
		
		@ViewBuilder var tipView : some View  {
			Group {
				switch self {
				case .swipeActions:
					EmptyView()
				case .journeySettingsFilterDisclaimer:
					EmptyView()
				case .followJourney:
					HowToFollowJourneyView()
				case .sunEvents:
					LegViewSettingsView(mode: .sunEvents)
				}
			}
			.padding(5)
		}
		
		@ViewBuilder var tipLabel : some View {
			switch self {
			case .swipeActions:
				Labels.SwipeActionsTip()
			case .journeySettingsFilterDisclaimer:
				Labels.JourneySettingsFilterDisclaimer()
			case .followJourney:
				EmptyView()
			case let .sunEvents(close, journey):
				Labels.SunEventsTipView(onClose: close, journey: journey)
			}
		}
	}
}

extension AppSettings.ChooTip {
	private struct Labels {
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
			@State var anim : AnimCase = .center0
			let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
			var body: some View {
				HStack(spacing: 0) {
					Group {
						Color.chewFillGreenSecondary
						Color.chewFillYellowPrimary
					}
					.frame(width: anim.leftCellsWidth)
					Color.black.opacity(0.6)
						.overlay{
							Text("journeys are swipable")
								.chewTextSize(.medium)
								.foregroundStyle(.secondary)
						}
					Color.chewFillRedPrimary
						.frame(width: anim.rightCellsWidth)
				}
				.background {
					Color.chewFillTertiary
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
							.tint(.gray)
					})
				}
			}
		}
		
		struct SunEventsTipView: View {
			let onClose : () -> ()
			let journey : JourneyViewData?
			var body: some View {
				Button(action: {
					Model.shared.sheetViewModel.send(
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
										color: $0.color.opacity(0.4),
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

extension AppSettings {
	func showTip(tip : ChooTipType) -> Bool {
		if !tipsToShow.contains(tip) {
			return false
		}
		switch tip {
		case .journeySettingsFilterDisclaimer,.followJourney,.swipeActions:
			return true
		case .sunEventsTip:
			if self.legViewMode != .colorfulLegs {
				return true
			}
			return false
		}
	}
}

#Preview(body: {
	AppSettings.ChooTip.swipeActions.tipLabel
		.padding()
})
