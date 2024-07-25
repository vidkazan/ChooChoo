//
//  APIAvailabilityMonitor.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 25.07.24.
//

import Foundation

class APIAvailabilityMonitor {
	private var timer: Timer?
	private let workerQueue = DispatchQueue(label: "APIMonitor")
	let monitorURL : URL? = URL(string: Constants.apiData.forPing)
	@Published var state : State = .available
	
	init() {
		startPinging()
	}
	
	func startPinging() {
		timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(pingURL), userInfo: nil, repeats: true)
	}
	
	func stopPinging() {
		timer?.invalidate()
		timer = nil
	}
	
	@objc private func pingURL() {
		if let url = monitorURL {
			let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
				if let error = error {
					self?.state = .unavailable
				} else if let response = response as? HTTPURLResponse {
					self?.state = .available
				}
			}
			task.resume()
		} else {
			state = .error(DataError.nilValue(type: "URL is nil"))
		}
	}
}

extension APIAvailabilityMonitor {
	enum State {
		case error(any ChewError)
		case available
		case unavailable
	}
}
