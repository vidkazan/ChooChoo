//
//  NetworkMonitor.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 20.01.24.
//

import Foundation
import Network

class NetworkMonitor {
	private let networkMonitor = NWPathMonitor()
	private let workerQueue = DispatchQueue(label: "Monitor")
	private weak var alertVM : TopBarAlertViewModel?

	init(send : @escaping (TopBarAlertViewModel.Event)->Void) {
		networkMonitor.pathUpdateHandler = { path in
			switch path.status {
			case .requiresConnection:
				send(.didRequestShow(.offline))
			case .satisfied:
				send(.didRequestDismiss(.offline))
			case .unsatisfied:
				send(.didRequestShow(.offline))
			@unknown default:
				fatalError("\(Self.self): unknown networkMonitor status")
			}
		}
		networkMonitor.start(queue: workerQueue)
	}
}

