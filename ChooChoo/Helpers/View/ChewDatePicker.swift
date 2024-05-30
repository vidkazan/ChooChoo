//
//  ChewDatePicker.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 22.01.24.
//

import Foundation
import SwiftUI

struct ChewDatePicker: UIViewRepresentable {
	
	@Binding var date: Date
	let mode : UIDatePicker.Mode
	let style : UIDatePickerStyle
	func makeUIView(context: Context) -> UIDatePicker {
		let picker = UIDatePicker()
		picker.datePickerMode = mode
		picker.minuteInterval = 5
		picker.setDate(date, animated: true)
		picker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
//		picker.locale = Locale(identifier: "en_GB")
		picker.isHidden = true
		Task {
			picker.preferredDatePickerStyle = style
			picker.isHidden = false
		}
		return picker
	}

	func updateUIView(_ datePicker: UIDatePicker, context: Context) {
		datePicker.date = date
	}

	func makeCoordinator() -> ChewDatePicker.Coordinator {
		return Coordinator(date: $date)
	}

	class Coordinator: NSObject {
		private let date: Binding<Date>

		init(date: Binding<Date>) {
			self.date = date
		}

		@objc func changed(_ sender: UIDatePicker) {
			self.date.wrappedValue = sender.date
		}
	}
}
