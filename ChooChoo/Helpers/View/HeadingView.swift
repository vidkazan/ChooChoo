//
//  HeadingView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.04.24.
//

import Foundation
import SwiftUI
import CoreLocation

struct HeadingView : View {
	@ObservedObject var locationManager = Model.shared.locationDataManager
	@State var heading : Double?
	let targetStopLocation : CLLocation
	var body: some View {
		Group {
			if let heading = heading {
				ChooSFSymbols.arrowUpCircle.view
					.tint(.secondary)
					.animation(nil, value: heading)
					.rotationEffect(Angle(radians: heading))
					.animation(.easeInOut, value: heading)
			}
		}
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
