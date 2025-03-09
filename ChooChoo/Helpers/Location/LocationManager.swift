//
//  LocationManager.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 14.09.23.
//

import Foundation
import CoreLocation
import OSLog
import SwiftUI
import Combine

class ChewLocationDataManager : NSObject, ObservableObject {
	private let locationManager = {
		let manager = CLLocationManager()
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.distanceFilter = 10
		manager.headingOrientation = .portrait
		return manager
	}()
	
	@Published var authorizationStatus: CLAuthorizationStatus? {
		didSet {
			Logger.locationManager.trace("status: \(self.authorizationStatus?.rawValue ?? -1)")
		}
	}
	@Published var heading: CLHeading?
	@Published var location: CLLocation?
	@Published var accuracyAuthorization: CLAccuracyAuthorization?
	
	private var isFollowingLocation = false
	
	override init() {
		super.init()
		locationManager.delegate = self
		location = locationManager.location
		accuracyAuthorization = locationManager.accuracyAuthorization
	}
	
	func reverseGeocoding(coords : Coordinate) async -> String? {
		if self.locationManager.location != nil,
		   let res = try? await CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coords.latitude, longitude: coords.longitude)).first,
		   let name = res.name, let city = res.locality {
			return  String(name + ", " + city)
		}
		return nil
	}
}

extension ChewLocationDataManager {
	func startUpdatingLocationAndHeading() {
		locationManager.startUpdatingHeading()
		locationManager.startUpdatingLocation()
		isFollowingLocation = true
	}
	func requestLocation() -> Coordinate? {
		Logger.locationManager.debug("didRequesLocation")
		if isFollowingLocation,
		   let coords = self.location?.coordinate {
			return Coordinate(coords)
		}
		locationManager.requestLocation()
		return nil
	}
	func stopUpdatingLocationAndHeading() {
		locationManager.stopUpdatingLocation()
		locationManager.stopUpdatingHeading()
		isFollowingLocation = false
	}
}

extension ChewLocationDataManager : CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.accuracyAuthorization = manager.accuracyAuthorization
		switch manager.authorizationStatus {
		case .authorizedWhenInUse:  // Location services are available.
			// Insert code here of what should happen when Location services are authorized
			authorizationStatus = .authorizedWhenInUse
			locationManager.requestLocation()
			break
			
		case .restricted:  // Location services currently unavailable.
			// Insert code here of what should happen when Location services are NOT authorized
			authorizationStatus = .restricted
			break
			
		case .denied:  // Location services currently unavailable.
			// Insert code here of what should happen when Location services are NOT authorized
			authorizationStatus = .denied
			break
		case .notDetermined:        // Authorization not determined yet.
			authorizationStatus = .notDetermined
			manager.requestWhenInUseAuthorization()
			break
		default:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		Logger.locationManager.debug("didUpdateLocation")
		self.location = locations.first
	}
	
	func locationManager(
		_ manager: CLLocationManager,
		didUpdateHeading newHeading: CLHeading
	) {
		self.heading = newHeading
	}
	
	
	func locationManager(
		_ manager: CLLocationManager,
		didFailWithError error: Error
	) {
		Logger.locationManager.error("\(error.localizedDescription)")
	}
}
