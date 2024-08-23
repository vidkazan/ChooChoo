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
	@State var journeyActions : [JourneyFollowData.JourneyAction]
    @State var current : UUID = .init()
	
	init(journeyActions: [JourneyFollowData.JourneyAction]) {
		self.journeyActions = journeyActions
        if let first = journeyActions.first?.id {
            _current = State(wrappedValue: first)
        }
	}
	var body: some View {
        if !journeyActions.isEmpty {
            Group {
                TabView(selection: $current) {
                    ForEach(journeyActions) { action in
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
                        .tag(action.id)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(height: 125)
                .padding(.top,-35)
                .padding(.bottom,-25)
                .onAppear{
                    update(referenceTime: chewVM.referenceDate)
                }
            }
        }
	}
}

extension JourneyActionsView {
    func update(referenceTime : ChewDate) {
		if let curr = journeyActions.first(where: {
			guard let time = $0.type.time(time: $0.stopData.time) else {
				return false
			}
            return time > referenceTime.date
        }) {
            current = curr.id
        }
	}
}
