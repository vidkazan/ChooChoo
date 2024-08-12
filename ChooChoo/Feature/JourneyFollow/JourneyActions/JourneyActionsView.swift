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
	@State var next : JourneyFollowData.JourneyAction?
	
	init(journeyActions: [JourneyFollowData.JourneyAction]) {
		self.journeyActions = journeyActions
	}
	var body: some View {
		Group {
			if let action = current {
				VStack {
					if let date = action.type.time(time: action.stopData.time) {
						HStack(spacing: 2) {
							BadgeView(.timeOffset(time: date))
								.badgeBackgroundStyle(.secondary)
							action.type.text()
								.chewTextSize(.medium)
								.foregroundStyle(.secondary)
							if action.type == .enter {
								PlatformView(isShowingPlatormWord: false, platform: action.type.platform(platform: action.stopData.platforms))
							}
							BadgeView(.generic(msg: action.stopData.name))
							Spacer()
						}
						if action.type == .enter {
							HStack(spacing: 2) {
								BadgeView(.lineNumberWithDirection(leg: action.leg))
									.badgeBackgroundStyle(.secondary)
								Spacer()
							}
						}
					}
				}
				.padding(5)
				.badgeBackgroundStyle(.secondary)
			}
		}
		.onAppear {
			update()
		}
		.onReceive(timer, perform: { _ in
			update()
		})
	}
}

extension JourneyActionsView {
	func update() {
		current = journeyActions.first(where: {
			guard let time = $0.type.time(time: $0.stopData.time) else {
				return false
			}
			return time > chewVM.referenceDate.date
		})
	}
}
