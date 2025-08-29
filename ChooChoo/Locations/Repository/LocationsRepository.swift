//
//  DatingRepository.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation

protocol LocationsRepository{
    func locations(
        lat: Float,
        lon: Float,
        
    ) async -> Result<[StopDTO], Error>
}
