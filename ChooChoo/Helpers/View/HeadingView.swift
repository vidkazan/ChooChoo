//
//  HeadingView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI
import CoreLocation
import OSLog


struct HeadingView : View {
	@ObservedObject var locationManager : ChewLocationDataManager
	@State var heading : Double?
	let targetStopLocation : CLLocation
	let arrowWIthCircle : Bool
	
	init(
		locationManager: ChewLocationDataManager = Model.shared.locationDataManager,
		targetStopLocation: CLLocation, 
		arrowWIthCircle: Bool = true
	) {
		self.locationManager = locationManager
		self.targetStopLocation = targetStopLocation
		self.arrowWIthCircle = arrowWIthCircle
	}
	
	var body: some View {
		Group {
			if let heading = heading {
				if arrowWIthCircle == true {
					ChooSFSymbols.arrowUpCircle.view
						.animation(nil, value: heading)
						.rotationEffect(Angle(radians: heading))
						.animation(.easeInOut, value: heading)
				} else {
					ChooSFSymbols.arrowUp.view
						.chewTextSize(.medium)
						.animation(nil, value: heading)
						.rotationEffect(Angle(radians: heading))
						.animation(.easeInOut, value: heading)
				}
			}
		}
		.tint(.secondary)
		.onReceive(locationManager.$heading, perform: { head in
			Task {
				if let loc = locationManager.location,
				   let deg = head?.trueHeading {
						self.heading = loc.bearingRadianTo(location: targetStopLocation) - deg * .pi/180
				}
			}
		})
	}
}
