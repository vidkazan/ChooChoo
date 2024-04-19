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
	@ObservedObject var viewModel = Model.shared.logViewModel

	var body: some View {
		VStack {
			switch viewModel.state.status {
			case .loading:
				ProgressView()
					.onTapGesture {
						Model.shared.logViewModel.send(event: .didCancelLoading)
					}
			case .loaded:
				if viewModel.state.entries.isEmpty {
					ErrorView(
						viewType: .alert,
						msg: Text(
							"No logs found",
							comment: "LogViewer: empty state"
						),
						size: .big,
						action: nil
					)
				} else {
					List(viewModel.state.entries, id: \.hashValue) { entry in
						LogEntryRow(entry: entry)
					}
					.listStyle(.plain)
				}
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
			Model.shared.logViewModel.send(event: .didTapLoading)
		}
		.navigationTitle("Logs")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: {
				Button(action: {
					Model.shared.logViewModel.send(event: .didTapLoading)
				}, label: {
					ChooSFSymbols.arrowClockwise.view
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

