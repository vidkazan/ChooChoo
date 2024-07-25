//
//  APIAvailabilityMonitor.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 25.07.24.
//

import Foundation

class APIAvailabilityMonitor  {
	private var timer: Timer?
	let monitorURL : URL? = URL(string: "https://"+Constants.apiData.urlBase + Constants.apiData.forPing)
	var delegate : APIAvailabilityMonitorDelegate? = nil
	
	init() {
		startPinging()
	}
	
	func startPinging() {
		pingURL()
		timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(pingURL), userInfo: nil, repeats: true)
	}
	
	func stopPinging() {
		timer?.invalidate()
		timer = nil
	}
	
	@objc private func pingURL() {
		if let url = monitorURL {
			let session = URLSession(configuration: .default)
			session.configuration.timeoutIntervalForRequest = 1
			session.configuration.timeoutIntervalForResource = 1
			let task = session.dataTask(with: url) { [weak self] data, response, error in
				if let _ = error {
					self?.delegate?.didUpdate(status: .unavailable)
				} else if let _ = response {
					self?.delegate?.didUpdate(status: .available)
				}
			}
			task.resume()
		} else {
			self.delegate?.didUpdate(status: .error(DataError.nilValue(type: "URL is nil")))
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

protocol APIAvailabilityMonitorDelegate {
	func didUpdate(status : APIAvailabilityMonitor.State)
}
