//
//  LocationsRepositoryImpl.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation
import Combine
import CoreLocation

final class LocationsRepositoryImpl: LocationsRepository {
	private let locationsEndpoint: LocationsEndpoint

	init(locationsEndpoint: LocationsEndpoint) {
        self.locationsEndpoint = locationsEndpoint
	}

    func locations(
        lat: Float,
        lon: Float
    ) async -> Result<[StopDTO], Error> {
        return .failure(ResponseError.generic(description: "not implemented"))
    }
}
