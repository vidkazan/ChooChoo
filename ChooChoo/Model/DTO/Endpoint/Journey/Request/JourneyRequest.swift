//
//  JourneyEndpointRequest.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation

protocol JourneyRequest : ChewDTO, Equatable {
    mutating func addJourneyListStops(
        dep : Stop,
        arr : Stop
    )
    
    mutating func addJourneyListTransfers(
        settings : JourneySettings
    )
    
    mutating func addJourneyListTransportModes(
        settings : JourneySettings
    )
    
    mutating func addJourneyListTime(
        time : Date,
        mode : LocationDirectionType
    )
    
    mutating func addJourneyOtherSettings(
        settings : JourneySettings
    )
}
