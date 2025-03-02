//
//  StopEndpoint.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

protocol StopResponse : ChewDTO, Identifiable {
    func stopDTO() -> StopDTO
}
