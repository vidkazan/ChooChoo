//
//  JourneyEndpointDTOintbahnde.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

protocol JourneyResponse : ChewDTO, Identifiable  {
    func journeyDTO() -> JourneyListDTO
}
