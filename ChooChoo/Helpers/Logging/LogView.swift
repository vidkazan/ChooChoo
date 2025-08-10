//
//  LogView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 19.04.24.
//

import Foundation
import SwiftUI
import OSLog

struct LogViewer: View {
	@ObservedObject var viewModel = Model.shared.logVM

	var body: some View {
		VStack {
			switch viewModel.state.status {
			case .loaded,.loading:
				List(viewModel.state.entries, id: \.hashValue) { entry in
					LogEntryRow(entry: entry)
				}
				.listStyle(.plain)
			case .error(let err):
				ErrorView(
					viewType: .error,
					msg: Text(verbatim: err.localizedDescription),
					size: .big,
					action: nil
				)
			}
		}
		.onAppear {
			Model.shared.logVM.send(event: .didTapLoading)
		}
		.navigationTitle("Logs")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: {
				Button(action: {
					switch viewModel.state.status {
					case .loading:
						Model.shared.logVM.send(event: .didCancelLoading)
					case .loaded:
						Model.shared.logVM.send(event: .didTapLoading)
					case .error:
						Model.shared.logVM.send(event: .didTapLoading)
					}
				}, label: {
					switch viewModel.state.status {
					case .loading:
						ProgressView()
                            .highPriorityGesture(
                                TapGesture().onEnded {
                                    Model.shared.logVM.send(event: .didCancelLoading)
                                }
                            )
					case .loaded:
						ChooSFSymbols.arrowClockwise.view
					case .error:
						ChooSFSymbols.exclamationmarkCircle.view
					}
				})
			})
		}
	}
}

struct LogEntryRow: View {
	let entry: OSLogEntryLog

	var body: some View {
		HStack {
			entry.color	
				.frame(width: 4)

			VStack(spacing: 12) {
				HStack {
					Text(entry.date, format: .iso8601)
					Spacer()
					Text(entry.category)
				}
				.foregroundColor(Color(uiColor: .secondaryLabel))

				Text(entry.composedMessage)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.font(.caption)
		}
	}
}

