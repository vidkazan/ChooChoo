//
//  ApiServiceErrors.swift.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation
import ChooNetworking


protocol ChooError : FcodyError {}

extension ApiError : ChooError {}
