//
//  RouteSheet.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 19.10.23.
//

import Foundation
import SwiftUI

struct RouteSheet: View {
	@EnvironmentObject var chewVM : ChewViewModel
	let leg : LegViewData
	var body: some View {
		ScrollView {
			LegDetailsView(
				send: { _ in },
				isExpanded: .expanded,
				leg: leg
			)
		}
		.chewTextSize(.big)
		.frame(maxWidth: .infinity)
	}
}

#if DEBUG
struct Preview : PreviewProvider {
	static var previews: some View {
		let mock = Mock.trip.RE6NeussMinden.decodedData
		if let mock = mock?.trip,
		   let viewData = mock.legViewData(firstTS: .now, lastTS: .now, legs: [mock]) {
			RouteSheet(leg: viewData)
				.environmentObject(ChewViewModel(coreDataStore: CoreDataStore.preview))
		} else {
			Text(verbatim: "error")
		}
	}
}
#endif
