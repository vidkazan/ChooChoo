//
//  ApiEndpoint.swift
//  Datify-iOS-Core
//
//  Created by Sergei Volkov on 10.03.2024.
//

import Foundation

protocol ApiEndpoint: RawRepresentable<String> {
    static var endpoint: String { get }
    var apiPath: String { get }
}

extension ApiEndpoint {
    var apiPath: String { Self.endpoint + self.rawValue }
}
