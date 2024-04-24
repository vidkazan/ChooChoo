//
//  SearchStopsView+subviews.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.09.23.
//
import SwiftUI

extension SearchStopsView {
	func textField(type : LocationDirectionType, text : Binding<String>) -> some View {
		return HStack(spacing: 0){
			TextField(type.placeholder, text: text.projectedValue)
				.submitLabel(.return)
				.keyboardType(.alphabet)
				.autocorrectionDisabled(true)
				.padding(10)
				.chewTextSize(.big)
				.frame(maxWidth: .infinity,alignment: .leading)
				.focused($focusedField, equals: type)
				.onChange(of: text.wrappedValue, perform: onTextChange )
				.onTapGesture {
					chewViewModel.send(event: .onStopEdit(type))
				}
				.onSubmit {
					searchStopViewModel.send(event: .onReset(type))
					chewViewModel.send(event: .didCancelEditStop)
//					chewViewModel.send(event: .onNewStop(.textOnly(text.wrappedValue), type))
				}
			HStack(spacing: 0) {
				if focusedField == type && text.wrappedValue.count > 0 {
					Button(action: {
						text.wrappedValue = ""
					}, label: {
						Image(.xmarkCircle)
							.chewTextSize(.big)
							.tint(.gray)
						
					})
					.frame(width: 40,height: 40)
				}
				if focusedField == type {
					Button(action: {
						chewViewModel.send(event: .didCancelEditStop)
						Model.shared.sheetVM.send(event: .didRequestShow(.mapPicker(type: type)))
					}, label: {
						Image(systemName: "map")
							.chewTextSize(.big)
							.tint(.primary)
					})
					.frame(width: 40,height: 40)
				}
			}
			Spacer()
		}
		.frame(maxHeight: 40)
	}
}

extension SearchStopsView {
	func onTextChange(text : String) {
		Task {
			guard
				case .editingStop(let type) = chewViewModel.state.status,
				searchStopViewModel.state.type == type else {
				return
			}
			if focusedField == searchStopViewModel.state.type && text.count > 2 {
				searchStopViewModel.send(event: .onSearchFieldDidChanged(text,type))
			}
			if focusedField == nil || text.isEmpty {
				searchStopViewModel.send(event: .onReset(type))
			}
		}
	}
}
