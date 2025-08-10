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
			if let leg = chewViewModel.state.data.getStop(type: type).leg {
				HStack(spacing: 0) {
					BadgeView(.lineNumberWithDirection(leg: leg))
//					Spacer()
//					CloseButton(action: {
//						chewViewModel.send(event: .didUpdateSearchData(
//							dep: .textOnly(""),
//							arr: chewViewModel.state.data.arrStop,
//							date: chewViewModel.state.data.date,
//							journeySettings: chewViewModel.state.data.journeySettings
//						))
//					})
				}
				.padding(5)
				.badgeBackgroundStyle(.secondary)
				.padding(5)
                .highPriorityGesture(
                    TapGesture().onEnded {
                        chewViewModel.send(event: .didUpdateSearchData(
                            dep: .textOnly(""),
                            arr: chewViewModel.state.data.arrStop,
                            date: chewViewModel.state.data.date,
                            journeySettings: chewViewModel.state.data.journeySettings
                        ))
                    }
                )
			} else {
				TextField(type.placeholder, text: text.projectedValue)
					.submitLabel(.return)
					.keyboardType(.alphabet)
					.autocorrectionDisabled(true)
					.padding(10)
					.chewTextSize(.big)
					.frame(maxWidth: .infinity,alignment: .leading)
					.focused($focusedField, equals: type)
					.onChange(of: text.wrappedValue, perform: onTextChange )
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            chewViewModel.send(event: .onStopEdit(type))
                        }
                    )
					.onSubmit {
						searchStopViewModel.send(event: .onReset(type))
						chewViewModel.send(event: .didCancelEditStop)
					}
			}
			HStack(spacing: 0) {
				if focusedField == type && text.wrappedValue.count > 0 {
					CloseButton(action: {
						text.wrappedValue = ""
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
