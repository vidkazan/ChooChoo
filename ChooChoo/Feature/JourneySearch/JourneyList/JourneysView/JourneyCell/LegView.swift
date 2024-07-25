//
//  LegView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.08.23.
//

import SwiftUI

struct LegViewLabels: View {
	var leg : LegViewData
	let bgColor : Color
	init(leg: LegViewData) {
		self.leg = leg
		switch leg.departureAndArrivalNotCancelledAndNotReachableFromPreviousLeg() {
		case true:
			switch leg.legType {
			case .footMiddle,.footStart,.footEnd:
				self.bgColor = Color.chewFillTertiary.opacity(0.5)
			case .line,.transfer:
				self.bgColor = Color.chewFillTertiary.opacity(0.8)
			}
		case false:
			self.bgColor =  Color.chewRedScale20
		}
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				RoundedRectangle(cornerRadius: 8)
					.fill(.clear)
					.overlay {
						switch leg.legType {
						case .footStart,.footMiddle,.footEnd:
							HStack(spacing: 2) {
								if (geo.size.width > 15) {
									Image(.figureWalkCircle)
										.font(.system(size: 12))
										.foregroundColor(.primary)
								}
								if let duration = DateParcer.timeDuration(leg.time.durationInMinutes) {
									if (Int(geo.size.width / 4) - 15 > duration.count) {
										Text(verbatim: duration)
											.foregroundColor(.primary)
											.chewTextSize(.medium)
									}
								}
							}
						case .line:
							Group {
								if (Int((geo.size.width - 15) / 7 ) > leg.lineViewData.name.count) {
									HStack(spacing: 0) {
										if let icon = leg.lineViewData.type.icon {
											Image(icon)
												.foregroundColor(.primary)
												.chewTextSize(.medium)
												.padding(1)
												.badgeBackgroundStyle(leg.lineViewData.type.iconBackgroundStyle)
										}
										Text(verbatim: leg.lineViewData.name.replacingOccurrences(of: " ", with: ""))
											.foregroundColor(.primary)
											.chewTextSize(.medium)
									}
								} else if (Int((geo.size.width - 15) / 7) > leg.lineViewData.shortName.count),
											let icon = leg.lineViewData.type.icon {
									HStack(spacing: 0) {
										Image(icon)
											.foregroundColor(.primary)
											.chewTextSize(.medium)
											.padding(1)
											.badgeBackgroundStyle(leg.lineViewData.type.iconBackgroundStyle)
										Text(verbatim: leg.lineViewData.shortName)
											.foregroundColor(.primary)
											.chewTextSize(.medium)
									}
								} else if (Int(geo.size.width) > 12),
											let icon = leg.lineViewData.type.icon {
									Image(icon)
										.foregroundColor(.primary)
										.chewTextSize(.medium)
										.padding(1)
										.badgeBackgroundStyle(leg.lineViewData.type.iconBackgroundStyle)
								}
							}
						case .transfer:
							EmptyView()
						}
					}
					.padding(.trailing,0.5)
			}
		}
	}
}


struct LegViewBG: View {
	var leg : LegViewData
	let screenWidth = UIScreen.main.bounds.width
	let bgColor : Color
	init(leg: LegViewData, mode : AppSettings.LegViewMode) {
		self.leg = leg
		switch leg.departureAndArrivalNotCancelledAndNotReachableFromPreviousLeg() {
		case true:
			switch leg.legType {
			case .footMiddle,.footStart,.footEnd:
				self.bgColor = Color.chewFillTertiary.opacity(0.5)
			case .line,.transfer:
				if mode.showColorfulLegs == true {
					self.bgColor = leg.lineViewData.type.color.opacity(0.5)
				} else {
					self.bgColor = Color.chewLegsViewGray.opacity(0.85)
				}
			}
		case false:
			self.bgColor =  Color.chewFillRedPrimary.opacity(0.8)
		}
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				RoundedRectangle(cornerRadius: 8)
					.fill(bgColor)
					.padding(.trailing,0.5)
			}
		}
	}
}
