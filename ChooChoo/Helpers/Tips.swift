//
//  Tips.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 08.03.24.
//

import Foundation
import TipKit
import SwiftUI

@available(iOS 17, *)
struct ChooTips {
	static let followJourney = ChooTipFollowJourney()
	static let searchNowButtonTip = ChooTipNowButton()
	static let searchTip = ChooTipSearch()
}

@available(iOS 17, *)
struct ChooTipSearch : Tip {
	var title: Text {
		Text("Search", comment: "search tip title")
	}
	var message: Text? {
		Text(
			"App does not have search button. **Search starts** after you set both **departure** and **arrival** stops.",
			comment: "search tip text"
		)
	}
	var image: Image? {
		Image(systemName: ChooSFSymbols.trainSideFrontCar.rawValue)
	}
}

@available(iOS 17, *)
struct ChooTipNowButton : Tip {
	var title: Text {
		Text("Search update", comment: "tip: now button: title")
	}
	var message: Text? {
		Text("If you want to update your search, simply press here",
			 comment: "tip: now button: text")
	}
	var image: Image? {
		Image(systemName: "hand.tap")
	}
}

@available(iOS 17, *)
struct ChooTipFollowJourney : Tip {
	var title: Text {
		Text("Follow journey",comment: "tip: follow journey: title")
	}
	var message: Text? {
		Text("Your followed journeys always appear on follow page.",
			 comment: "tip: follow journey: title")
	}
	var image: Image? {
		Image(systemName: ChooSFSymbols.bookmark.rawValue)
	}
}

struct HowToFollowJourneyView : View {
	@State var isPressed : Bool = false
	let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
	var body: some View {
		HStack {
			Spacer()
			Text("Journey Details",
				 comment: "info sheet: follow journey button: view name"
			)
				.chewTextSize(.big)
			Spacer()
			Group {
				ChooSFSymbols.bookmark.view
					.symbolVariant(isPressed ? .fill : .none )
				ChooSFSymbols.arrowClockwise.view
			}
			.foregroundStyle(.blue)
			.frame(width: 15,height: 15)
			.padding(5)
		}
		.onReceive(timer, perform: { _ in
			withAnimation {
				isPressed.toggle()
			}
		})
		.padding(10)
		.background(.regularMaterial)
		.clipShape(.rect(cornerRadius: 10, style: .continuous))
		.padding(10)
	}
}
