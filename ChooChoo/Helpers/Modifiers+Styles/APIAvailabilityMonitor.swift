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
	var currentTask : URLSessionTask? = nil
	
	init() {
		startPinging()
	}
	
	func startPinging() {
		pingURL()
		timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(pingURL), userInfo: nil, repeats: true)
	}
	
	func stopPinging() {
		timer?.invalidate()
		timer = nil
	}
	
	@objc private func pingURL() {
		if let url = monitorURL {
			let session = URLSession(configuration: .default)
			let request = URLRequest(url: url,timeoutInterval: 3)
			if currentTask == nil {
				currentTask = session.dataTask(with: request) { [weak self] data, response, error in
					if let error = error {
						self?.delegate?.didUpdate(status: .unavailable)
						return
					}
					guard let response = response as? HTTPURLResponse else {
						return
					}
					switch response.statusCode {
					case 503,500:
						self?.delegate?.didUpdate(status: .unavailable)
					default:
						self?.delegate?.didUpdate(status: .available)
					}
					self?.currentTask = nil
				}
			}
			currentTask?.resume()
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
