//
//  BadgeView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 24.08.23.
//

import Foundation
import SwiftUI

struct ChewLabel : View {
	let text : Text?
	let string : String?
	let image : String
	
	init(_ text : Text?, _ image : String) {
		self.text = text
		self.string = nil
		self.image = image
	}
	init(_ text : Text?, _ image : ChooSFSymbols) {
		self.text = text
		self.string = nil
		self.image = image.rawValue
	}
	init(_ string : String?,_ image : String) {
		self.string = string
		self.text = nil
		self.image = image
	}
	init(_ string : String?,_ image : ChooSFSymbols) {
		self.string = string
		self.text = nil
		self.image = image.rawValue
	}
	var body : some View {
		HStack(spacing: 2) {
			Image(systemName: image)
			if let text = text {
				text
			}
			if let string = string {
				Text(verbatim: string)
			}
		}
	}
}

struct OneLineText : View {
	let text : Text?
	let string : String?
	let strikethrough : Bool
	
	init(_ text : Text,_ strikethrough : Bool = false) {
		self.text = text
		self.string = nil
		self.strikethrough = strikethrough
	}
	init(_ string : String,_ strikethrough : Bool = false) {
		self.string = string
		self.text = nil
		self.strikethrough = strikethrough
	}
	var body : some View {
		Group {
			if let text = text {
				text
					.strikethrough(strikethrough)
					.lineLimit(1)
			}
			if let string = string {
				Text(verbatim: string)
					.strikethrough(strikethrough)
					.lineLimit(1)
			}
		}
	}
}

struct BadgeView : View {
	var badge : Badges
	let size : ChewPrimaryStyle
	let color : Color = .chewFillTertiary
	init(
		_ badge : Badges,
		_ size : ChewPrimaryStyle = .medium,
		color : Color? = nil
	) {
		self.badge = badge
		self.size = size
	}
	var body : some View {
		Group {
			switch badge {
			case let .lineNumberWithDirection(leg):
				HStack(spacing: 0) {
					BadgeView(.lineNumber(lineType: leg.lineViewData.type, num: "\(leg.lineViewData.name)"),size)
					BadgeView(.prognosedlegDirection(dir: leg.direction, strikethrough: false, multiline: false),size)
				}
			case let .prognosedlegDirection(dir,strikethrough, multiline):
				Group {
					if let actual = dir.actual, let planned = dir.planned {
						Group {
							if actual != planned {
								HStack(spacing: 0) {
									BadgeView(.legDirection(dir: actual, strikethrough: strikethrough, multiline: multiline),size)
										.padding(.trailing,-3)
									BadgeView(.legDirection(dir: planned, strikethrough: true, multiline: multiline),size)
										.foregroundStyle(.secondary)
								}
							} else {
								BadgeView(.legDirection(dir: actual, strikethrough: strikethrough, multiline: multiline),size)
							}
						}
					} else if let planned = dir.planned {
						BadgeView(.legDirection(dir: planned, strikethrough: strikethrough, multiline: multiline),size)
					}
				}
			case let .legDirection(dir,strikethrough, multiline):
				Text(verbatim: dir)
					.strikethrough(strikethrough)
					.lineLimit(multiline ? 3 : 1)
					.chewTextSize(size)
					.padding(4)
			case .distance(let dist):
				OneLineText(
					Text(Measurement(
						value: dist,
						unit: UnitLength.meters
					)
					.formatted(.measurement(width: .abbreviated).attributed))
				)
				.chewTextSize(size)
				.padding(4)
			case .price(let price):
				OneLineText(
					Text(price, format: .currency(code: "EUR"))
				)
					.chewTextSize(size)
					.padding(4)
			case
				 .cancelled,
				 .generic,
				 .connectionNotReachable,
				 .routeError,
				 .followError,
				 .locationError,
				.apiUnavaiable,
				 .offlineMode,
				 .updateError:
				OneLineText(badge.badgeData.text)
					.chewTextSize(size)
					.padding(4)
			case let .timeDepartureTimeArrival(time):
				if let dep = time.date.departure.actualOrPlannedIfActualIsNil(),
				   let arr = time.date.arrival.actualOrPlannedIfActualIsNil() {
					OneLineText(
						Text(
							verbatim: DateParcer.getTimeStringFromDate(
								date: dep
							) ?? ""
						)
//						Text(dep, style: .time)
						+
						Text(verbatim: "-")
						+
//						Text(arr, style: .time)
						Text(
							verbatim: DateParcer.getTimeStringFromDate(
								date: arr
							) ?? ""
						)
					)
					.chewTextSize(size)
					.padding(4)
				}
			case .date(let date):
				OneLineText(Text(date, style: .date))
					.chewTextSize(size)
					.padding(4)
			case let .updatedAtTime(refTime, isLoading):
				UpdatedAtBadgeView(
					bgColor: self.color,
					refTime: refTime,
					isLoading: isLoading
				)
					.chewTextSize(size)
					.padding(4)
			case .remarkImportant:
				OneLineText(badge.badgeData.text)
					.foregroundColor(.white)
					.chewTextSize(size)
					.padding(.horizontal,4)
					.padding(4)
			case let .lineNumber(type, _):
				if let image = type.icon {
					HStack(spacing:0) {
						Image(image)
							.padding(1)
							.cornerRadius(10)
							.badgeBackgroundStyle(type.iconBackgroundStyle)
						.foregroundColor(Color.primary)
						.chewTextSize(size)
						OneLineText(badge.badgeData.text)
							.foregroundColor(Color.primary)
							.chewTextSize(size)
					}
					.padding(4)
					.badgeBackgroundStyle(
						BadgeBackgroundGradientStyle(
							colors: (type.color,type.color.opacity(0.7))
						)
					)
				}
			case .stopsCount(let count,let mode):
				HStack(spacing: 2) {
					OneLineText(badge.badgeData.text)
						.chewTextSize(size)
					if count > 1, mode != .hideShevron {
						Image(.chevronDown)
							.chewTextSize(size)
							.rotationEffect(.degrees(mode.angle))
							.transition(.opacity)
							.animation(.spring(), value: mode)
					}
				}
				.padding(4)
			case .legDuration(let time):
				if let dur = DateParcer.timeDuration(time.durationInMinutes) {
					OneLineText(Text(verbatim: "\(dur)"))
					.chewTextSize(size)
					.padding(4)
				}
			case .walking:
					ChewLabel(
						badge.badgeData.text,
						.figureWalkCircle
					)
					.chewTextSize(size)
					.padding(4)
			case .transfer:
					ChewLabel(
						badge.badgeData.text,
						.arrowLeftArrowRight
					)
					.chewTextSize(size)
					.padding(4)
			case .changesCount(let count):
				ChewLabel(String("\(count)"),.arrowLeftArrowRight)
					.chewTextSize(size)
					.padding(4)
			case let .departureArrivalStops(departure,arrival):
				(
					Text(verbatim: departure)
					+
					Text(" to ", comment: "badge: departureArrivalStops")
					+
					Text(verbatim: arrival)
				)
				.chewTextSize(size)
				.padding(4)
			}
		}
	}
}

//
//
//@available(iOS 16.0, *)
//struct BadgeViewPreview : PreviewProvider {
//	static var previews: some View {
//		if let viewData = Mock.journeys.journeyNeussWolfsburg.decodedData?.journey.journeyViewData(depStop: .init(), arrStop: .init(), realtimeDataUpdatedAt: 0,settings: .init()) {
//			VStack {
//				FlowLayout {
//						BadgeView(.lineNumber(lineType: .national, num: "ICE666"))
//						BadgeView(.lineNumber(lineType: .regional, num: "RE666"))
//						BadgeView(.lineNumber(lineType: .bus, num: "Bus666"))
//						BadgeView(.lineNumber(lineType: .tram, num: "Tram 700"))
//						BadgeView(.lineNumber(lineType: .ferry, num: "Schiff"))
//						BadgeView(.lineNumber(lineType: .suburban, num: "S6"))
//						BadgeView(.lineNumber(lineType: .subway, num: "U6"))
//				}
//				FlowLayout {
//					BadgeView(.routeError)
//						.badgeBackgroundStyle(.red)
//					BadgeView(.followError(.deleting))
//						.badgeBackgroundStyle(.red)
//					BadgeView(.locationError)
//						.badgeBackgroundStyle(.red)
//					BadgeView(.offlineMode)
//						.badgeBackgroundStyle(.blue)
//				}
//				FlowLayout {
//					BadgeView(.timeDepartureTimeArrival(timeContainer: viewData.time))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.changesCount(3))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.departureArrivalStops(
//						departure: "Blablablablabla Hbf",
//						arrival: "Plaplaplaplapla Hbf"),
//							  .big)
//					.badgeBackgroundStyle(.primary)
//					BadgeView(.remarkImportant(remarks: []))
//						.badgeBackgroundStyle(.red)
//					BadgeView(.cancelled)
//						.badgeBackgroundStyle(.red)
//					BadgeView(.connectionNotReachable)
//						.badgeBackgroundStyle(.red)
//					BadgeView(.date(date: .now))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.legDuration(viewData.time))
//						.badgeBackgroundStyle(.primary)
//				}
//				FlowLayout {
//					BadgeView(.legDirection(dir: "Tudasudadudabuda Hbf",strikethrough: false))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.legDirection(dir: "Tudasudadudabuda Hbf",strikethrough: false),.big)
//					.badgeBackgroundStyle(.primary)
//					BadgeView(.price(50))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.stopsCount(10,.showShevronDown),.medium)
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.transfer(viewData.time))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.walking(viewData.time))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.updatedAtTime(referenceTime: 1705930000,isLoading: true))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.updatedAtTime(referenceTime: 1705930000,isLoading: false))
//						.badgeBackgroundStyle(.primary)
//					BadgeView(.distanceInMeters(dist: 100))
//						.badgeBackgroundStyle(.primary)
//				}
//			}
//		}
//	}
//}
