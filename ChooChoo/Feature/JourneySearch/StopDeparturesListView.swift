//
//  StopDeparturesListView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 09.08.24.
//

import Foundation
import SwiftUI

struct StopDeparturesListView : View {
	let departures : [LegViewData]?
	var body: some View {
		if let trips = departures {
			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 0) {
					ForEach(
						trips,
						id: \.hashValue
					) { trip in
						Button(action: {
							Model.shared.sheetVM.send(
								event: .didRequestShow(.route(leg: trip))
							)
						}, label: {
							DeparturesListCellView(trip: trip)
						})
					}
				}
			}
		}
	}
}
