//
//  DatingRepository.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation
import CoreLocation
import Combine

protocol LocationsRepository{
    func locations(
        lat: Float,
        lon: Float
    ) async -> Result<[StopDTO], Error>
}
