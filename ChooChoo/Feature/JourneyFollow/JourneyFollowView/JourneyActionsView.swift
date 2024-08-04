//
//  JourneyActionsView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 04.08.24.
//

import Foundation
import SwiftUI

struct JourneyActionsView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let journeyActions : [JourneyFollowData.JourneyAction]
	@State var current : JourneyFollowData.JourneyAction?
	var body: some View {
		if let action = current {
			VStack {
				let date : Date? = action.type.time(
					time: action.stopData.time
				).actualOrPlannedIfActualIsNil()
				
				if let date = date {
					HStack(spacing: 2) {
						BadgeView(.timeOffset(time: date))
							.badgeBackgroundStyle(.secondary)
						PlatformView(isShowingPlatormWord: false, platform: action.type.platform(platform: action.stopData.platforms))
						BadgeView(.generic(msg: action.stopData.name))
						Spacer()
					}
					HStack(spacing: 2) {
						BadgeView(.lineNumberWithDirection(leg: action.leg))
							.badgeBackgroundStyle(.secondary)
						Spacer()
					}
				}
			}
			.onAppear {
				update()
			}
			.onReceive(timer, perform: { _ in
				update()
			})
		.padding(5)
		.badgeBackgroundStyle(.secondary)
		}
	}
}

extension JourneyActionsView {
	func update() {
		current = journeyActions.first(where: {
			guard let time =  $0.type.time(time: $0.stopData.time).actualOrPlannedIfActualIsNil() else {
				return false
			}
			return time > chewVM.referenceDate.date
		})
	}
}
