//
//  DatePickerView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 24.08.23.
//

import SwiftUI

struct DatePickerView: View {
	@EnvironmentObject private var chewVM : ChewViewModel
	@State var date : Date
	@State var time : Date
	@State private var type : LocationDirectionType = .departure
	let closeSheet : ()->Void

	var body: some View {
			VStack(alignment: .center,spacing: 5) {
				ChewDatePicker(date: $time,mode: .time, style: .wheels)
					.scaleEffect(0.85)
					.frame(maxWidth: .infinity,maxHeight: 140)
					.padding(5)
				Picker(
					selection: $type,
					content: {
						ForEach(LocationDirectionType.allCases, id: \.rawValue) {
							Text($0.description)
								.tag($0)
						}
					},
					label: {}
				)
				.pickerStyle(.segmented)
				if #available(iOS 16.0, *) {
					ChewDatePicker(date: $date,mode: .date, style: .inline)
	//					.scaleEffect(0.9)
						.frame(maxWidth: .infinity,maxHeight: 320)
						.padding(5)
						.background(Color.chewFillTertiary.opacity(0.15))
						.cornerRadius(10)
				} else {
					ChewDatePicker(date: $date,mode: .date, style: .inline)
						.scaleEffect(0.9)
						.frame(maxWidth: .infinity,maxHeight: 320)
						.padding(5)
						.background(Color.chewFillTertiary.opacity(0.15))
						.cornerRadius(10)
				}
				DatePickerTimePresetButtons(closeSheet: closeSheet, mode: type)
				Spacer()
			}
			.padding(.horizontal,10)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing, content: {
					Button(action: {
						Task {
							if let dateCombined = DateParcer.getCombinedDate(
								date: date,
								time: time
							) {
								chewVM.send(
									event: .didUpdateSearchData(
										date: SearchStopsDate(
											date: .specificDate(dateCombined.timeIntervalSince1970),
											mode: type
										)
									)
								)
								closeSheet()
							}
						}
					}, label: {
						Text("Save", comment: "datePickerView: save button")
							.chewTextSize(.big)
							.frame(maxWidth: 100,maxHeight: 43)
					})
				}
			)}
	}
}
