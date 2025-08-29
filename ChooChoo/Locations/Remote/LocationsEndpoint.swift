//
//  DatingEndpoint.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation

protocol LocationsEndpoint{
    func getLocations(
        lat: Float,
        lon: Float
    ) async -> Result<[any StopResponse], ResponseError>
}

